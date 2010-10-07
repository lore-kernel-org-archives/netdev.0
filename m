From: <Narendra_K@Dell.com>
Subject: Re: [PATCH] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 19:44:57 +0530
Message-ID: <20101007141433.GA2641@libnet-test.oslab.blr.amer.dell.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com>
 <20100922192228.GB29899@kroah.com>
 <EDA0A4495861324DA2618B4C45DCB3EE6A0AF8@blrx3m08.blr.amer.dell.com>
 <20100923152730.GA1261@kroah.com>
 <EDA0A4495861324DA2618B4C45DCB3EE6A0AFD@blrx3m08.blr.amer.dell.com>
 <20100923163336.GA15603@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100923163336.GA15603@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2010 at 10:03:36PM +0530, Greg KH wrote:
>    On Thu, Sep 23, 2010 at 09:20:57PM +0530, Narendra_K@Dell.com wrote:
>    > > Now trying to change the kernel namespace itself seems like a bad hack
>    > > around this fact.
>    > >
>    >
>    > The patch does not change the existing kernel name space.
> 
>    You are "reordering it", right?
> 
>    > It adheres to the existing ethN name space with IFNAMSIZ length
>    > requirements. The patch only makes sure that eth0 always corresponds
>    > to what is labeled as 'Gb1' on server chassis, on systems where SMBIOS
>    > type 41 record is available. And removes the need for any renames for
>    > the interfaces which have a firmware index assigned by system
>    > firmware, as the very first name assigned by the kernel will be as
>    > expected and deterministic.
> 
>    And on systems with buggy firmware, what is going to happen here?  And
>    yes, there will be buggy BIOS tables, we can guarantee that, as this is
>    not something that Windows supports, right?
> 

It took some time to find out the details asked above. Right, windows
does not use SMBIOS type 41 record to derive names. But as a datapoint,
windows also has the same problem.

Yes, firmware and BIOS tables can be buggy. How about a command line
parameter 'no_netfwindex', passing which firmware index will not be
used to derive ethN names ? That would handle the scenario of buggy
firmware and names will be derived in the now existing way.

I will submit a patch shortly implementing this.

-- 
With regards,
Narendra K

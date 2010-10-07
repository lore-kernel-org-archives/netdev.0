From: Tim Small <tim@seoss.co.uk>
Subject: Re: [PATCH] Use firmware provided index to register a network interface
Date: Thu, 07 Oct 2010 15:27:00 +0100
Message-ID: <4CADD8B4.10102@seoss.co.uk>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com> <20100922192228.GB29899@kroah.com> <EDA0A4495861324DA2618B4C45DCB3EE6A0AF8@blrx3m08.blr.amer.dell.com> <20100923152730.GA1261@kroah.com> <EDA0A4495861324DA2618B4C45DCB3EE6A0AFD@blrx3m08.blr.amer.dell.com> <20100923163336.GA15603@kroah.com> <20101007141433.GA2641@libnet-test.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	Matt_Domsch@Dell.com, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com, Vijay_Nijhawan@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20101007141433.GA2641@libnet-test.oslab.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/10/10 15:14, Narendra_K@Dell.com wrote:
> Yes, firmware and BIOS tables can be buggy. How about a command line
> parameter 'no_netfwindex', passing which firmware index will not be
> used to derive ethN names ? That would handle the scenario of buggy
> firmware and names will be derived in the now existing way.
>
> I will submit a patch shortly implementing this.
>    

What was the reason for not doing this in user space again?  You stated 
that you got races when doing renames like eth0 -> eth2, but the 
solution looked like renaming into a different name space such as eth0 
-> ethlom2  etc. so that it wouldn't race with the names handed out by 
the kernel?

Tim.

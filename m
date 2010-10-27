From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Wed, 27 Oct 2010 08:46:04 -0700 (PDT)
Message-ID: <20101027.084604.226761472.davem@davemloft.net>
References: <1288075928.6578.185.camel@concordia>
	<20101026133233.GH15074@solarflare.com>
	<1288135235.16778.14.camel@concordia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, somnath.kotur@emulex.com,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: michael@ellerman.id.au
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1288135235.16778.14.camel@concordia>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Ellerman <michael@ellerman.id.au>
Date: Wed, 27 Oct 2010 10:20:35 +1100

> On Tue, 2010-10-26 at 14:32 +0100, Ben Hutchings wrote:
>> Michael Ellerman wrote:
>> > On Mon, 2010-10-25 at 16:25 -0700, David Miller wrote:
>> > > From: Ben Hutchings <bhutchings@solarflare.com>
>> > > Date: Mon, 25 Oct 2010 23:38:53 +0100
> 
>> > Ethtool would be nice, but only for network drivers. Is there a generic
>> > solution, quirks are obviously not keeping people happy.
>>  
>> Since this is (normally) a property of the system, pci=nomsi is the
>> generic solution.
> 
> Sort of, it's a big hammer. Did all these driver writers not know about
> pci=nomsi or did they prefer to add a parameter to their driver for some
> reason?

Every time I've actually done the work to try and track down the
true issue, it always turned out to be a PCI chipset problem rather
than a device specific issue.

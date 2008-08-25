From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [sky2, solved] transmit timeouts and firmware update...
Date: Mon, 25 Aug 2008 15:22:06 -0400
Message-ID: <20080825152206.2d554cf7@speedy>
References: <6278d2220808250742r4a2b377al13a516fa0c6b53a9@mail.gmail.com>
	<alpine.LNX.1.10.0808252048440.25225@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>,
	Linux Networking <linux-net@vger.kernel.org>,
	Daniel J Blueman <daniel.blueman@gmail.com>
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0808252048440.25225@bizon.gios.gov.pl>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Aug 2008 21:03:25 +0200 (CEST)
Krzysztof Oledzki <ole@ans.pl> wrote:

> 
> 
> On Mon, 25 Aug 2008, Daniel J Blueman wrote:
> 
> > I (and a lot of other users) have been experiencing the frequent sky2
> > transmit timeout problem [1] (on 88E8053/Yukon2 EC gig hardware); this
> > is a result of the embedded NIC controller locking up, and I've found
> > that updating the firmware addresses this issue. I'm still seeing a
> > previous and different issue [2] from time to time though (silicon
> > bug?).
> 
> Thanks for the info. I've been dealing with this problem for some long 
> time, hopefully sky driver from the latest kernels is able to recover 
> from such hangs, so it is not that critical problem now.
> 
> > Marvell shipping broken firmware is completely unpublicised or
> > acknowledged, however updated firmware is available through your
> > motherboard vendor, so all hope it not lost after all...
> 
> Unfortunately not through all vendors. :( Or maybe not *yet*?
> 
> > My 8053/EC is using firmware 2.2 (previously 1.9) - you can check in
> > DOS with 'yukondg.exe' from
> > http://www.marvell.com/drivers/files/yukondg_v6.53.4.3.zip .
> 
> Stephen, is it possible for sky2 driver to check and print the 
> firmware version?

It is possible to dump and program eeprom from linux, and the version
maybe buried in the VPD, but some hardware has non-functional VPD.

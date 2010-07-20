From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: net/dsa
Date: Tue, 20 Jul 2010 15:59:50 +0200
Message-ID: <20100720135950.GZ14513@mail.wantstofly.org>
References: <4C3B8231.6020706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Karl Beldan <karl.beldan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:55654 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab0GTN7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 09:59:54 -0400
Content-Disposition: inline
In-Reply-To: <4C3B8231.6020706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 12, 2010 at 10:59:29PM +0200, Karl Beldan wrote:

> Hi,

Hi Karl,

Sorry, I didn't see your mail initially -- please CC me in the future.


> I found the dsa code very handy to help manage a switch.

Ah.  What particular part are you using?


> Yet I was surprised I had to tweak the code to simply use the phy
> layer state machine.

You mean that net/dsa uses phy_attach() but not phy_start_machine() ?
Have you seen problems arising from this?


> And I don't see much activity in the code nor any discussion, e.g no
> follow up to http://patchwork.ozlabs.org/patch/16578.
> 
> So I was wondering if there was anybody playing with this code, or
> having ideas about features to add (vlan/stp callbacks) ?

As far as I know, the code currently in the kernel works well for what
it intends to do (which is to just expose the switch ports), and I'm
not aware of any bugs in it.

That said, you're right in that there are several more features that
the hardware supports that the software could be extended to handle.

For one, I don't have access to any Marvell switch chip hardware
anymore, so that limits my ability to play with this.  Also, the
relevant documentation is under a rather restrictive license, so the
only way I can see net/dsa support for Marvell parts improving is if
there's pressure from a large enough customer to make this happen.

If this is about non-Marvell parts, I'd welcome adding support for
those into net/dsa.  For one, I would really like to see Broadcom
switch chip support added -- the documentation for those chips is
under similarly restrictive licensing, though.


thanks,
Lennert

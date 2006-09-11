From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Mon, 11 Sep 2006 14:59:01 -0500
Message-ID: <4505C005.2070302@lwfinger.net>
References: <45021D4A.6040805@lwfinger.net> <20060909152305.GA27080@tuxdriver.com> <4502E62B.5060601@lwfinger.net> <20060911192846.GB19326@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stefano Brivio <st3@riseup.net>,
	Michael Buesch <mb@bu3sch.de>,
	Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:11953 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S965007AbWIKT7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 15:59:14 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060911192846.GB19326@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Sat, Sep 09, 2006 at 11:04:59AM -0500, Larry Finger wrote:
>> John W. Linville wrote:
> 
> OK, I see now.  The patch won't apply to the upstream branch at all
> due to the open-coded locking patch applied previously.
> 
> The problem now is that if I send this up for 2.6.18 then it creates
> some messiness in the git repositories.  Plus, it still might not
> make 2.6.18 because it is already very late.
> 
> I think I will have to ask you to hold-on to this until Linus
> officially releases 2.6.18.  Then you can/should send this patch to
> the stable team (stable@vger.kernel.org) for inclusion in 2.6.18.1
> or later.

I will do that as soon as 18 is released. I don't want that bug in the 
wild too long.
> 
> I have these:
> 
> Date	Title
> ----	-----
> 8/21	bcm43xx-softmac: Init, shutdown and restart fixes
> 8/30	WE-21 for bcm43xx
> 9/3	remove dead code from bcm43xx-softmac
> 9/4	add firmware version printout
> 9/6	ucode debug status via sysfs
> 9/7	remove dead code in bcm43xx_sysfs.c
> 
> The first has not been merged because I haven't seen a reply to
> Michael's last comments in that thread.  The WE-21 patch has not been
> merged because I haven't merged the WE-21 stuff yet.  The others are
> all from last week, which I just haven't processed yet.
> 
> Will you be responding to Michael's comments on the "Init, shutdown
> and restart fixes" patch?

That has already been sent. As I said in that message, it looks as if 
the first patch has already been merged; therefore, I sent only the 
patch to move the step that Michael noted. If that is not true, let me 
know.

> P.S.  For some reason, I often have trouble applying your patches.
> I'm not sure what process you are using to generate your patches, but
> please make sure that your patches can be successfully applied when
> your email is fed to 'git applymbox'.  If you use git, the output of
> 'git format-patch' should be usable.
> 
> Also, if you could just use "---" instead of a long line of "======",
> I think I would have to do less manual processing...thanks!

Sorry about the === rather than ---. Is that documented somewhere?

I use quilt to generate the patches, but will check them with git in 
the future.

In addition to the items listed above, my list for wireless-2.6 includes:

8/15  bcm43xx: >1G and 64bit DMA support
8/15  bcm43xx: re-add bcm43xx_rng_init() call
8/15  Add Larry Finger to bcm43xx MAINTAINERS
8/16  bcm43xx-softmac: optimization of DMA bitfields.
8/19  bcm43xx: return correct hard_start_xmit error code]
9/10  Change PHY initialization to match updated clean-room specs

The first 3 were submitted by Michael before I took over.

I hope I'm not causing too much trouble while I learn the ropes.

Larry



From: Steve Kieu <haiquy@yahoo.com>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Wed, 31 Aug 2005 10:09:48 +1000 (EST)
Message-ID: <20050831000948.40799.qmail@web53607.mail.yahoo.com>
References: <20050830152908.1dc24339@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Daniel Drake <dsd@gentoo.org>, Steve Kieu <haiquy@yahoo.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932300AbVHaAKF@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050830152908.1dc24339@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Hemminger <shemminger@osdl.org> wrote:

> On Wed, 31 Aug 2005 07:49:37 +1000 (EST)

> > 
> > install-8_23.tar.bz2
> 
> Just look for references to CHIP_REV_YU_LITE_A3 in
> the driver
> 	sk98lin/skgeinit.c and sk98lin/skxmac2.c
> The comparison should always be:

Have a look but no clue to patch it, there are one
instance of comparing

> 	pAC->GIni.GIChipRev >= CHIP_REV_YU_LITE_A3
> otherwise it will not correctly take chip out of
> powerdown (coma) mode.

please send me a patch to the install-8_23.tar.bz2
then I can test. Or intruct more details, which line
and what should change then I can do manually.

I have nerver done device driver programming in my
life!



> 


S.KIEU

Send instant messages to your online friends http://au.messenger.yahoo.com 

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [2.6.31-git17] WARNING: at kernel/hrtimer.c:648 hres_timers_resume+0x40/0x50()/WARNING: at drivers/base/sys.c:353 __sysdev_resume+0xc3/0xe0()
Date: Sun, 27 Sep 2009 20:17:43 +0200
Message-ID: <200909272017.43348.rjw@sisk.pl>
References: <8db1092f0909270105x4b49daf8k268e453d2379020c@mail.gmail.com> <2674af740909270749u339671a1ia81d5736eeb750fa@mail.gmail.com> <8db1092f0909270916k79d0c369ub93b5e8ddf66c979@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Yong Zhang <yong.zhang0@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	clemens@ladisch.de, venkatesh.pallipadi@intel.com, gregkh@suse.de,
	zambrano@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: Maciej Rutecki <maciej.rutecki@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752091AbZI0SQT@vger.kernel.org>
In-Reply-To: <8db1092f0909270916k79d0c369ub93b5e8ddf66c979@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 27 September 2009, Maciej Rutecki wrote:
> 2009/9/27 Yong Zhang <yong.zhang0@gmail.com>:
> >
> > It seem this is cause by b44 dirver. Can you give a try?
> >
> > From 05ee2f22a7ea065e05bf8b5294d222a3700d2cc8 Mon Sep 17 00:00:00 2001
> > From: Yong Zhang <yong.zhang0@gmail.com>
> > Date: Sun, 27 Sep 2009 22:42:41 +0800
> > Subject: [PATCH] net/b44: keep irq state at suspend_resume
> >
> > suspend() and resume() assume irq is disabled. So keep the irq
> > state when do this.
> 
> Remove previous patch, add it to clean 2.6.31-git17. It doesn't help.

It couldn't.  The problem is elswhere, but I haven't found it yet.

Thanks,
Rafael

From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: linux-next: Tree for September 3
Date: Fri, 5 Sep 2008 00:45:33 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0809050041520.3243@apollo.tec.linutronix.de>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au> <20080903214634.ea17ff53.akpm@linux-foundation.org> <alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org> <20080903223318.84b6ce8b.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org> <20080904012544.cabed847.akpm@linux-foundation.org> <alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org> <20080904015701.5959623a.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org> <20080904104554.32ffebea.akpm@linux-foundation.org> <alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org> <20080904113408.d47c65f6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Sam Ravnborg <sam@ravnborg.org>,
	john stultz <johnstul@us.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:42279 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006AbYIDWvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 18:51:03 -0400
In-Reply-To: <20080904113408.d47c65f6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Sep 2008, Andrew Morton wrote:
> 
> and oh dear, the clockevents code just oopsed.

Sigh.
 
> BUG: unable to handle kernel NULL pointer dereference at 00000040
> IP: [<c0126e7f>] get_next_timer_interrupt+0xe9/0x1ab

Cute, NULL pointer in the timer check code. Can you please addr2line
the exact code line or upload the vmlinux somewhere ?

Thanks,

	tglx

From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?Re[2]=3A_[PATCH_v8]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Sun, 22 Aug 2010 11:17:45 +0400
Message-ID: <E1On4oL-0008EI-00.xeb-mail-ru@f230.mail.ru>
References: <20100821.230309.104050634.davem@davemloft.net>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: xiaosuo@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f230.mail.ru ([217.69.128.160]:37951 "EHLO f230.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab0HVHRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 03:17:53 -0400
In-Reply-To: <20100821.230309.104050634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller <davem@davemloft.net>
> Date: Sat, 21 Aug 2010 23:01:29 -0700 (PDT)
> 
> > From: Changli Gao <xiaosuo@gmail.com>
> > Date: Sat, 21 Aug 2010 20:42:09 +0800
> > 
> >> I think the following lines from your patch are also useful, and you'd
> >> better move them above the "---" marker.
> > 
> > I'll take care of this when applying his patch.
> > 
> > Also this patch was against net-2.6 or even something
> > earlier, so there were many patch rejects I had to fix
> > up against include/linux/if_pppox.h when applying this
> > to net-next-2.6
> 
> It also doesn't even build against anything even remotely
> recent:
> 
> drivers/net/pptp.c: In function ?pptp_xmit?:
> drivers/net/pptp.c:204: error: ?struct rtable? has no member named ?u?
> drivers/net/pptp.c:271: error: ?struct rtable? has no member named ?u?
> drivers/net/pptp.c:279: error: ?struct rtable? has no member named ?u?
> drivers/net/pptp.c:283: error: ?struct rtable? has no member named ?u?
> drivers/net/pptp.c:288: error: ?struct rtable? has no member named ?u?
> drivers/net/pptp.c: In function ?pptp_connect?:
> drivers/net/pptp.c:483: error: ?struct rtable? has no member named ?u?
> drivers/net/pptp.c:485: error: ?struct rtable? has no member named ?u?
> drivers/net/pptp.c: In function ?pptp_init_module?:
> drivers/net/pptp.c:675: error: implicit declaration of function ?__vmalloc?
> drivers/net/pptp.c:676: warning: assignment makes pointer from integer without a cast
> drivers/net/pptp.c:707: error: implicit declaration of function ?vfree?
> 
> That means this patch is against a tree which is at least two
> releases old.  We got rid of the 'u' member of struct rtable
> quite some time ago.
> 
> Ugh, I'll fix this up, but after _8_, yes _EIGHT_, iterations of this
> patch set the amount of problems that remain is completely
> unbelievable.

Sorry, maybe it is wrong, but i did patch using repository git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git, HEAD at a63ecd835f075b21d7d5cef9580447f5fbb36263.
Have i update and resend it for net-next-2.6 ?

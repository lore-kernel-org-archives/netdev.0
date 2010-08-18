From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?Re=3A_[PATCH_v3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Wed, 18 Aug 2010 14:38:58 +0400
Message-ID: <E1Olg2s-0007BB-00.xeb-mail-ru@f30.mail.ru>
References: <1282119905.2194.38.camel@edumazet-laptop>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f30.mail.ru ([217.69.129.95]:45649 "EHLO f30.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638Ab0HRKjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 06:39:01 -0400
In-Reply-To: <1282119905.2194.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric!
Thanks for comments. All your comments was accepted except:

> > +static struct ppp_channel_ops pptp_chan_ops = {
> 
> static const ?

not, because po->chan.ops = &pptp_chan_ops which is not const

> > +static DEFINE_RWLOCK(gre_proto_lock);
> 
> This could use RCU and a spinlock instead
> 

rcu + mutex

Patch v4 will be ready soon...

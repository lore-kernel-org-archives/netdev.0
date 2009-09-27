From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
Date: Sun, 27 Sep 2009 21:02:08 +0200
Message-ID: <20090927190208.GA3549@del.dom.local>
References: <20090921201157.GA5460@del.dom.local>
 <4ABA9058.3010605@free.fr>
 <20090925131038.GA14778@ff.dom.local>
 <20090925134052.GA1661@linux-mips.org>
 <20090925183504.GA3307@del.dom.local>
 <20090927072319.GA28089@linux-mips.org>
 <20090927171029.GA3297@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:4657 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbZI0TDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2009 15:03:08 -0400
Content-Disposition: inline
In-Reply-To: <20090927171029.GA3297@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 27, 2009 at 07:10:29PM +0200, Jarek Poplawski wrote:
...
> In this case valid calls (return 0) were affected too, so I guess the
> whole thing is rarely used.

And, after all, there would be only a little, invisible memory leak.

Jarek P.

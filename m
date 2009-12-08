From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes of heavy surfing
Date: Mon, 7 Dec 2009 16:19:35 -0800 (PST)
Message-ID: <138412.20552.qm@web52903.mail.re2.yahoo.com>
References: <20091207135342.6fb07264.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52903.mail.re2.yahoo.com ([206.190.49.13]:41839 "HELO
	web52903.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965148AbZLHAT3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 19:19:29 -0500
In-Reply-To: <20091207135342.6fb07264.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Mon, 7/12/09, Andrew Morton <akpm@linux-foundation.org> wrote:
> A regression in the latest 2.6.31 -stable tree.
> 
> Are you really really sure that you applied that patch,
> recompiled, reinstalled, etc?

Yup, 'fraid so. And because you asked so nicely, I've just managed to reproduce the problem having first done "make distclean" and "make oldconfig", followed by "make" :-). (This was with F12's latest compiler gcc 4.4.2 20091027, BTW.) The symptom was the same - a complete system freeze without anything written to the serial console. So it's just a *guess* that it's network-related, but it does always seem to happen while I'm waiting for a web page to load in my browser...

I saw something interesting in 2.6.31.7 about a crash due to fragmentation:

ipv4: additional update of dev_net(dev) to struct *net in ip_fragment.c, NULL ptr OOPS

I'll try applying that patch too, to see if it makes any difference. Along with that other UDP-related thing I noticed:

udp: Fix udp_poll() and ioctl()

Cheers,
Chris


      

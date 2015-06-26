From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: macb napi strange behavior
Date: Sat, 27 Jun 2015 01:15:22 +0200
Message-ID: <20150626231522.GC28820@electric-eye.fr.zoreil.com>
References: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
 <5581C27C.4040408@ni.com>
 <CAH=tA9HCqKgSFwMczRJ1hb=Sjb1H5XFg00ddRq=BW+_8OZ0ARQ@mail.gmail.com>
 <CAGVrzcZxPqyp3CDLc-UQejtVg1QVv5OBuGLQNVSrtfG9H1OUnA@mail.gmail.com>
 <20150620164332.GA2505@electric-eye.fr.zoreil.com>
 <CAH=tA9F+hhKvbGaTb7j9km4niRR3K89MEgjz=aah9rB4A_tG4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Jaeden Amero <jaeden.amero@ni.com>,
	netdev <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Josh Cartwright <joshc@ni.com>,
	"David S. Miller" <davem@davemloft.net>,
	Bogdan Chifor <chiforbogdan86@gmail.com>
To: Nicolae Rosia <nicolae.rosia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55150 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbFZXPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 19:15:50 -0400
Content-Disposition: inline
In-Reply-To: <CAH=tA9F+hhKvbGaTb7j9km4niRR3K89MEgjz=aah9rB4A_tG4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolae Rosia <nicolae.rosia@gmail.com> :
[...]
> I gave it a shot. Can you please take a look?
> I don't know how to deal with multiple queues since Zynq 7000 has one
> queue per interface.

macb_interrupt knows the queue. macb_poll doesn't. Either you store it
somewhere or you go for per queue napi struct.

-- 
Ueimor

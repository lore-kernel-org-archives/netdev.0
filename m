From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: macb napi strange behavior
Date: Sat, 20 Jun 2015 18:43:32 +0200
Message-ID: <20150620164332.GA2505@electric-eye.fr.zoreil.com>
References: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
 <5581C27C.4040408@ni.com>
 <CAH=tA9HCqKgSFwMczRJ1hb=Sjb1H5XFg00ddRq=BW+_8OZ0ARQ@mail.gmail.com>
 <CAGVrzcZxPqyp3CDLc-UQejtVg1QVv5OBuGLQNVSrtfG9H1OUnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolae Rosia <nicolae.rosia@gmail.com>,
	Jaeden Amero <jaeden.amero@ni.com>,
	netdev <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Josh Cartwright <joshc@ni.com>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40788 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbbFTQn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 12:43:57 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcZxPqyp3CDLc-UQejtVg1QVv5OBuGLQNVSrtfG9H1OUnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> :
[...]
> Typically, NAPI is used at the receive side of the Ethernet NIC/driver
> to lower the hard/soft interrupt context switch, although there is
> nothing that prevent you to implement a similar scheme for the
> transmit side. Usually, for transmit you will be submitting one packet
> for transmission and get a completion interrupt, so without interrupt
> coalescing (software or hardware) you can end-up with 1 interrupt per
> packet transmitted.

The wording is a bit shy: there is a long standing policy to move
everything to NAPI context (as well as go mostly lockless, etc.).

Any taker to move macb Tx processing to NAPI context or should I consider it ?

-- 
Ueimor

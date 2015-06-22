From: Nicolae Rosia <nicolae.rosia@gmail.com>
Subject: Re: macb napi strange behavior
Date: Mon, 22 Jun 2015 22:04:47 +0300
Message-ID: <CAH=tA9E2MvxvKg=YLYBNppMsJVpn-xHmua2rDZFSzrrMy7rPHw@mail.gmail.com>
References: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
	<5581C27C.4040408@ni.com>
	<CAH=tA9HCqKgSFwMczRJ1hb=Sjb1H5XFg00ddRq=BW+_8OZ0ARQ@mail.gmail.com>
	<CAGVrzcZxPqyp3CDLc-UQejtVg1QVv5OBuGLQNVSrtfG9H1OUnA@mail.gmail.com>
	<20150620164332.GA2505@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Jaeden Amero <jaeden.amero@ni.com>,
	netdev <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Josh Cartwright <joshc@ni.com>,
	"David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:35104 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbFVTEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 15:04:49 -0400
Received: by lagi2 with SMTP id i2so26353219lag.2
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 12:04:47 -0700 (PDT)
In-Reply-To: <20150620164332.GA2505@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2015 at 7:43 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Florian Fainelli <f.fainelli@gmail.com> :
> [...]
>> Typically, NAPI is used at the receive side of the Ethernet NIC/driver
>> to lower the hard/soft interrupt context switch, although there is
>> nothing that prevent you to implement a similar scheme for the
>> transmit side. Usually, for transmit you will be submitting one packet
>> for transmission and get a completion interrupt, so without interrupt
>> coalescing (software or hardware) you can end-up with 1 interrupt per
>> packet transmitted.
>
> The wording is a bit shy: there is a long standing policy to move
> everything to NAPI context (as well as go mostly lockless, etc.).
>
> Any taker to move macb Tx processing to NAPI context or should I consider it ?
>
I can help with testing!

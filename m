From: chetan loke <loke.chetan@gmail.com>
Subject: Re: time stamping packets (on Rx side)
Date: Fri, 16 Mar 2012 16:37:29 -0400
Message-ID: <CAAsGZS72pKdOhsf11VG1y=CHhvjBW02q_Om7dnBvAa=raswdyA@mail.gmail.com>
References: <CAAsGZS4OvqyRr-1vvTzW5+Lx5007tuwP5GsZHRDXEOY4q1Mw1A@mail.gmail.com>
	<20120316071039.GC2199@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47670 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517Ab2CPUhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 16:37:31 -0400
Received: by ghrr11 with SMTP id r11so4628034ghr.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 13:37:29 -0700 (PDT)
In-Reply-To: <20120316071039.GC2199@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 16, 2012 at 3:10 AM, Richard Cochran
<richardcochran@gmail.com> wrote:

>
> Not sure what you mean by NIC/host side.
>
> But, yes, time stamping every received packet in the MAC is a nice

Yup, that's what I meant.


> Some cards can provide a time stamp in the frame or in its control
> block, and thus time stamp every packet. The Intel 82580 can do this,

aaaah, I somehow missed the following - (rx_desc,
E1000_RXDADV_STAT_TSIP) check in the code.


> HTH,
> Richard
>
thanks
Chetan

From: Nicolae Rosia <nicolae.rosia@gmail.com>
Subject: Re: macb napi strange behavior
Date: Wed, 17 Jun 2015 22:00:58 +0300
Message-ID: <CAH=tA9HCqKgSFwMczRJ1hb=Sjb1H5XFg00ddRq=BW+_8OZ0ARQ@mail.gmail.com>
References: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
	<5581C27C.4040408@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Josh Cartwright <joshc@ni.com>
To: Jaeden Amero <jaeden.amero@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:34781 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999AbbFQTA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 15:00:59 -0400
Received: by labbc20 with SMTP id bc20so39660420lab.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 12:00:58 -0700 (PDT)
In-Reply-To: <5581C27C.4040408@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jun 17, 2015 at 9:54 PM, Jaeden Amero <jaeden.amero@ni.com> wrote:
> On 06/17/2015 11:09 AM, Nicolae Rosia wrote:
> The times we've seen tons of interrupts on Ethernet with interrupts
> routed through the PL was when the FPGA was unprogrammed (or in the
> process of being reprogrammed), or was configured with the interrupt
> line tied to asserted.
>
> In the latter case, Linux would eventually stop handling any more
> interrupts for that port due to the interrupt storm.
>
This isn't the case. The FPGA is programmed, and indeed I'm using the
second MAC routed through PL to SFP.
The interesting thing is that I'm seeing the exact behavior on the
other side (another Zynq7 board), with eth0 having lots of interrupts.
It seems that the interface receiving packets doesn't have a high IRQ
activity in contrast to the one sending packets.

From: Martin Josefsson <gandalf@mjufs.se>
Subject: Re: Intel 82599 ixgbe driver performance
Date: Wed, 10 Aug 2011 21:18:08 +0200
Message-ID: <CAP1qwHj3Vb7Ci8QPkvx_dR0zouO7AZB1o8fB53TuOp69Dj5Qsw@mail.gmail.com>
References: <4E4222F6.7050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: "J.Hwan Kim" <frog1120@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:49046 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730Ab1HJTSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 15:18:09 -0400
Received: by qwk3 with SMTP id 3so702943qwk.19
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 12:18:08 -0700 (PDT)
In-Reply-To: <4E4222F6.7050304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2011 at 8:19 AM, J.Hwan Kim <frog1120@gmail.com> wrote:

> I'm testing our network card which includes intel 82599 based on ixgbe driver.
> I wonder what is the Rx performance of i82599 without network stack only with 64Byte frames.
> Our driver reads the packet directly from DMA packet buffer and push to the application
> without passing through linux kernel stack.
> It seems that the intel 82599 cannot push 64B frames to DMA area in 10G.
> Is it right?
>
> If it is the case, what is the bottleneck of 82599?

My experience with 82599 is that it can RX 13.4 Mpps using 64byte
frames and a single port.
When using both ports the rate drops to 10.7 Mpps per port.

Note that my experience does not involve the ixgbe driver, these
numbers were obtained using a custom driver and OS, but should give
some indication of what the hardware is capable of.

(If you want to see something "fun", try 65byte packets with 82599 and
the Intel X58 IOH (or 5500/5520 server versions) :)

--
/Martin

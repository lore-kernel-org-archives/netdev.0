From: "Christoph Gysin" <christoph.gysin@fr33z3.org>
Subject: [OT] Re: 8139too in >=2.6.26: SIOCSIFFLAGS: Device or resource busy
Date: Mon, 15 Dec 2008 15:28:45 +0100
Message-ID: <6f67b0190812150628i5939f50k57176fdf0ee7c805@mail.gmail.com>
References: <6f67b0190812100251u511d0aect4d082541977335d9@mail.gmail.com>
	 <20081210210435.GA30537@electric-eye.fr.zoreil.com>
	 <6f67b0190812110405y4f8b2498t6ae9a97a3faf4d5@mail.gmail.com>
	 <20081211201837.GA25911@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:53803 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791AbYLOO2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 09:28:46 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1106865yxm.1
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 06:28:45 -0800 (PST)
In-Reply-To: <20081211201837.GA25911@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/12/11 Francois Romieu <romieu@fr.zoreil.com>:
> I was not clear enough: can you do a diff of the complete boot messages ?
> For instance:
> $ dmesg > dmesg-2.6.25
> [change kernel]
> $ dmesg > dmesg-2.6.26
> $ diff -upN dmesg-2.6.25 dmesg-2.6.26
>
> Rationale:
> 1. the 8139too driver underwent almost no change between 2.6.25 and 2.6.26
> 2. rtl8139_open can only fail because of request_irq
>
> It is not clear that the issue is in the 8139too driver itself.

I managed to get the device working even with recent kernels by using
a stock ubuntu kernel configuration. Now I wonder what caused the poor
performance.

As you can see from the performance results, throughput decreases
gradually during the test. This is reproducible. I only get back to
the inital throughput after a reboot. I'm also wondering what could
cause the huge difference between Rx and Tx throughput.

Any guesses are greatly appreciated.

This is OT now, as the problem seems not to be related to the driver
anymore. Sorry for the noise.

Christoph
-- 
echo mailto: NOSPAM !#$.'<*>'|sed 's. ..'|tr "<*> !#:2" org@fr33z3

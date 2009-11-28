From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH] NET: smc91x: Fix irq flags
Date: Sat, 28 Nov 2009 23:15:13 +0800
Message-ID: <f17812d70911280715v50f48298rd5a469e393235a95@mail.gmail.com>
References: <20091128101323.GA25671@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:21262 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbZK1PP1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:15:27 -0500
Received: by qw-out-2122.google.com with SMTP id 3so439819qwe.37
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 07:15:33 -0800 (PST)
In-Reply-To: <20091128101323.GA25671@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 28, 2009 at 6:13 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> smc91x.h defines SMC_IRQ_FLAGS to be -1 when it wants the interrupt
> flags to be taken from the resource structure. =C2=A0However, d280ead
> changed this to checking for non-zero resource flags.
>
> Unfortunately, this means that on some platforms, we end up passing
> '-1' to request_irq rather than the desired result. =C2=A0Combine the=
 two
> conditions into one so that the IRQ flags are taken from the resource
> if either SMC_IRQ_FLAGS is -1 or the resource flags specify an
> interrupt trigger.
>
> This restores network on at least the Versatile platform.
>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Acked-by: Eric Miao <eric.y.miao@gmail.com>

From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH v8 RESEND] ARM: net: JIT compiler for packet filters
Date: Tue, 27 Mar 2012 11:41:32 +0200
Message-ID: <CAN9tCgSi_Lat+i3LqNGWGCk01cmJTvLfD-mXTHhks9od-nj6Gg@mail.gmail.com>
References: <1331933316-10197-1-git-send-email-mgherzan@gmail.com>
	<20120319.172005.1889334604020296555.davem@davemloft.net>
	<4F6EEAB5.7070009@gmail.com>
	<20120325095711.GC5611@n2100.arm.linux.org.uk>
	<4F6F19C2.60602@gmail.com>
	<20120325133506.GG5611@n2100.arm.linux.org.uk>
	<20120327075600.GL5611@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:43395 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab2C0Jld convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 05:41:33 -0400
Received: by pbcun15 with SMTP id un15so12404pbc.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 02:41:32 -0700 (PDT)
In-Reply-To: <20120327075600.GL5611@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/3/27 Russell King - ARM Linux <linux@arm.linux.org.uk>:
> Mircea, could you please supply an ack for the below fix to silence a
> warning. =A0Thanks.
>
> 8<=3D=3D=3D=3D=3D
> ARM: fix Kconfig warning for HAVE_BPF_JIT
>
> Last night's randconfig and the allnoconfig builds spat out the
> following warning while building:
>
> warning: (ARM) selects HAVE_BPF_JIT which has unmet direct dependenci=
es (NET)
>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
> =A0arch/arm/Kconfig | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 9e21b6e..6a54606 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -33,7 +33,7 @@ config ARM
> =A0 =A0 =A0 =A0select GENERIC_IRQ_SHOW
> =A0 =A0 =A0 =A0select CPU_PM if (SUSPEND || CPU_IDLE)
> =A0 =A0 =A0 =A0select GENERIC_PCI_IOMAP
> - =A0 =A0 =A0 select HAVE_BPF_JIT
> + =A0 =A0 =A0 select HAVE_BPF_JIT if NET
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0The ARM series is a line of low-power-consumption =
RISC chip designs
> =A0 =A0 =A0 =A0 =A0licensed by ARM Ltd and targeted at embedded appli=
cations and

Acked-by: Mircea Gherzan <mgherzan@gmail.com>

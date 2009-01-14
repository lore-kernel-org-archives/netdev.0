From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: do tx at the right position
Date: Wed, 14 Jan 2009 18:59:19 +0100
Message-ID: <200901141859.19609.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955495-11911-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:37877 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbZANR7g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:59:36 -0500
Received: by mail-bw0-f21.google.com with SMTP id 14so2167071bwz.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 09:59:35 -0800 (PST)
In-Reply-To: <1231955495-11911-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:51:35 Phil Sutter, vous avez =E9crit=A0=
:
> Triggering TX before the write to the DMA status mask register leads =
to
> transferring packets with maximum payload no matter what the actual
> packet size is.
> While here, also trigger RX scheduling after writing the DMA status m=
ask
> register, like it was in the original driver before it was sent
> upstream.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

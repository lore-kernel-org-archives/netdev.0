From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: do not use IRQF_SHARED with IRQF_DISABLED
Date: Wed, 14 Jan 2009 19:00:50 +0100
Message-ID: <200901141900.51134.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955540-12886-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:55262 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbZANSBL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 13:01:11 -0500
Received: by bwz14 with SMTP id 14so2170327bwz.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 10:01:08 -0800 (PST)
In-Reply-To: <1231955540-12886-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:52:20 Phil Sutter, vous avez =E9crit=A0=
:
> As the kernel warning states: "IRQF_DISABLED is not guaranteed on sha=
red
> IRQs". Since these IRQs' values are hardcoded and my test system does=
n't
> show any shared use of IRQs at all, rather make them non-shared than
> non-disabled.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

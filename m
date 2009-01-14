From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: rework korina_rx() for use with napi
Date: Wed, 14 Jan 2009 18:58:50 +0100
Message-ID: <200901141858.50275.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955461-11187-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:37877 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbZANR7J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:59:09 -0500
Received: by bwz14 with SMTP id 14so2167071bwz.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 09:59:06 -0800 (PST)
In-Reply-To: <1231955461-11187-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:51:01 Phil Sutter, vous avez =E9crit=A0=
:
> This function needs an early exit condition to function properly, or
> else caller assumes napi workload wasn't enough to handle all receive=
d
> packets and korina_rx is called again (and again and again and ...).
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>
Acked-by: Florian Fainelli <florian@openwrt.org>

--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

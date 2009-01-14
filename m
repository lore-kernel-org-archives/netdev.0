From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: fix handling tx_chain_tail
Date: Wed, 14 Jan 2009 19:00:14 +0100
Message-ID: <200901141900.14616.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955510-12240-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:61981 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbZANSIQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 13:08:16 -0500
Received: by fxm13 with SMTP id 13so146455fxm.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 10:08:14 -0800 (PST)
In-Reply-To: <1231955510-12240-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:51:50 Phil Sutter, vous avez =E9crit=A0=
:
> Originally this must have been a rewrite error when introducing
> 'chain_index'. But the original driver did not use the previous chain
> item everywhere: when altering the address tx_chain_tail points to, i=
t
> should move forward, not backwards.

I think this was in the original driver as well.

> Also this is not an "index" but rather the penultimate element in the
> chain, so rename it accordingly.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

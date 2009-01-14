From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: reset resource buffer size to 1536
Date: Wed, 14 Jan 2009 18:57:50 +0100
Message-ID: <200901141857.50984.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:42562 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbZANR6J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:58:09 -0500
Received: by bwz14 with SMTP id 14so2165469bwz.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 09:58:07 -0800 (PST)
In-Reply-To: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:50:00 Phil Sutter, vous avez =E9crit=A0=
:
> The new value is the one used in the external patch before and allows=
 at
> least a standard MTU of 1500 to be handled correctly. Impact of this
>
> change gets visible when bigger packets are to be received, issuing:
> | ping -s 492 <IP>
>
> and bigger payload sized led to 100% packet loss.

Thanks

>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org

--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: do schedule napi after testing for it
Date: Wed, 14 Jan 2009 18:59:04 +0100
Message-ID: <200901141859.05053.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955478-11495-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:51509 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbZANR7X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:59:23 -0500
Received: by fk-out-0910.google.com with SMTP id 18so375852fkq.5
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 09:59:21 -0800 (PST)
In-Reply-To: <1231955478-11495-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:51:18 Phil Sutter, vous avez =E9crit=A0=
:
> The called netif_rx_schedule() does all the work for us:
> - it checks the return value of netif_rx_schedule_prep() and
> - if everything is ok calls __netif_rx_schedule().
> Before this change, the driver received absolutely nothing.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>

--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

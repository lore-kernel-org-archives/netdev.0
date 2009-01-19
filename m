From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: adjust headroom for new skb's also
Date: Mon, 19 Jan 2009 22:07:45 +0100
Message-ID: <200901192207.46383.florian@openwrt.org>
References: <1232058598-15811-1-git-send-email-n0-1@freewrt.org> <20090115223020.A7EED4043838@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f20.google.com ([209.85.219.20]:57282 "EHLO
	mail-ew0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757717AbZASVHy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:07:54 -0500
Received: by ewy13 with SMTP id 13so608920ewy.13
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 13:07:52 -0800 (PST)
In-Reply-To: <20090115223020.A7EED4043838@mail.nwl.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thursday 15 January 2009 23:29:56 Phil Sutter, vous avez =E9crit=A0:
> This is copy and paste from the original driver. As skb_reserve() is
> also called within korina_alloc_ring() when initially allocating the
> receive descriptors, the same should be done when allocating new spac=
e
> after passing an skb to upper layers.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

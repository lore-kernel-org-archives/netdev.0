From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: dsa: introduce MICREL KSZ8893MQL/BL ethernet
 switch chip support
Date: Wed, 21 Jul 2010 17:33:13 +0200
Message-ID: <1279726393.2452.60.camel@edumazet-laptop>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	 <1279719442-10174-2-git-send-email-vapier@gentoo.org>
	 <20100721151608.GM21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Karl Beldan <karl.beldan@gmail.com>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:43227 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab0GUPdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 11:33:18 -0400
Received: by ewy23 with SMTP id 23so2347083ewy.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 08:33:17 -0700 (PDT)
In-Reply-To: <20100721151608.GM21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 juillet 2010 =C3=A0 17:16 +0200, Lennert Buytenhek a =C3=
=A9crit :

> > +#define pr_fmt(fmt) "ksz8893m: " fmt
>=20
> This has no users.
>=20

Dont tell this to Joe Perches ;)

It is used by all pr_err() friends

#define pr_emerg(fmt, ...) \
        printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
#define pr_alert(fmt, ...) \
        printk(KERN_ALERT pr_fmt(fmt), ##__VA_ARGS__)
#define pr_crit(fmt, ...) \
        printk(KERN_CRIT pr_fmt(fmt), ##__VA_ARGS__)
#define pr_err(fmt, ...) \
        printk(KERN_ERR pr_fmt(fmt), ##__VA_ARGS__)
#define pr_warning(fmt, ...) \
        printk(KERN_WARNING pr_fmt(fmt), ##__VA_ARGS__)
#define pr_warn pr_warning
#define pr_notice(fmt, ...) \
        printk(KERN_NOTICE pr_fmt(fmt), ##__VA_ARGS__)
#define pr_info(fmt, ...) \
        printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
#define pr_cont(fmt, ...) \
        printk(KERN_CONT fmt, ##__VA_ARGS__)



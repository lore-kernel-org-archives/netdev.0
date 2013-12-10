From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 2/2] bgmac: use phy_mii_ioctl in ioctl handler
Date: Tue, 10 Dec 2013 10:51:51 +0100
Message-ID: <CACna6rzzji6oQbBQmx5JKUpVpbFaMEaoPF5QRewFy8+Mydr9wQ@mail.gmail.com>
References: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
	<1386668966-24562-2-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>
To: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:49491 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789Ab3LJJvv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 04:51:51 -0500
Received: by mail-ob0-f177.google.com with SMTP id va2so5021128obc.22
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 01:51:51 -0800 (PST)
In-Reply-To: <1386668966-24562-2-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/10 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> From: Hauke Mehrtens <hauke@hauke-m.de>
>
> This works pretty much the same way, so avoid duplicating the code.
>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

I forgot "git am" and "git format-patch" drop my comments. There is goe=
st:

> This ports part of Hauke's patch from OpenWrt.
>
> Hauks: I've just dropped
> if (!bgmac->phydev)
> return -EINVAL;
> as we are guaranteed to have PHY dev.

From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: only the AT8030 needs a hardware reset
 on link change
Date: Tue, 26 Apr 2016 19:46:09 -0700
Message-ID: <572027F1.9000009@gmail.com>
References: <1461692658-1742-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
	davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33688 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbcD0CqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 22:46:13 -0400
Received: by mail-oi0-f47.google.com with SMTP id v145so2523290oie.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 19:46:13 -0700 (PDT)
In-Reply-To: <1461692658-1742-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/04/2016 10:44, Timur Tabi a =C3=A9crit :
> Commit 13a56b44 ("at803x: Add support for hardware reset") added a
> work-around for a hardware bug on the AT8030.  However, the work-arou=
nd
> was being called for all 803x PHYs, even those that don't need it.
> Function at803x_link_change_notify() checks to make sure that it only
> resets the PHY on the 8030, but it makes more sense to not call that
> function at all if it isn't needed.
>=20
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

This looks nicer indeed!
--=20
=46lorian

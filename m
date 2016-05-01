From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] macb: fix mdiobus_scan() error check
Date: Sun, 1 May 2016 09:03:43 -0700
Message-ID: <572628DF.4060004@gmail.com>
References: <2317306.aZN9iKAKYz@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35363 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbcEAQDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 12:03:45 -0400
Received: by mail-ob0-f175.google.com with SMTP id n10so68635288obb.2
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 09:03:45 -0700 (PDT)
In-Reply-To: <2317306.aZN9iKAKYz@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/04/2016 15:47, Sergei Shtylyov a =C3=A9crit :
> Now mdiobus_scan() returns ERR_PTR(-ENODEV) instead of NULL if the PH=
Y
> device ID was read as all ones. As this was not  an error before, thi=
s
> value  should be filtered out now in this driver.
>=20
> Fixes: b74766a0a0fe ("phylib: don't return NULL from get_phy_device()=
")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian

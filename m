From: Tim Harvey <tharvey@gateworks.com>
Subject: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
Date: Fri, 7 Apr 2017 07:47:17 -0700
Message-ID: <CAJ+vNU1UG2EeJSTStT_BJ+RiRe4a8YwfRgnE6DsRghTLetq_rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
        Lucas Stach <l.stach@pengutronix.de>,
        Fugang Duan <fugang.duan@nxp.com>,
        Koen Vandeputte <koen.vandeputte@ncentric.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36362 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933650AbdDGOrT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:47:19 -0400
Received: by mail-wm0-f45.google.com with SMTP id o81so45921386wmb.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 07:47:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

I've had a couple of users report that they are getting occasional
link drops when using IMX6 FEC on our boards which are using a Marvell
88E1510 PHY:

[ 9348.474418] fec 2188000.ethernet eth0: MDIO read timeout
[ 9350.478804] fec 2188000.ethernet eth0: Link is Down

If they bring the interface back up it works fine.

The most recent version of Linux they have tested and seen this on is
v4.9 with CONFIG_MARVELL_PHY=y

Has anyone else run into this or know what the issue could be? Should
there be any retries at the MDIO level or above?

Regards,

Tim

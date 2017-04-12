From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
Date: Wed, 12 Apr 2017 09:16:04 -0700
Message-ID: <CAJ+vNU3u8JGXfXU6z6Rk4ur2j14q00jiXJB13f8MRN8_F1SFMQ@mail.gmail.com>
References: <CAJ+vNU1UG2EeJSTStT_BJ+RiRe4a8YwfRgnE6DsRghTLetq_rg@mail.gmail.com>
 <AM4PR0401MB2260310769B1983FAE5D7814FF010@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Lucas Stach <l.stach@pengutronix.de>,
        Koen Vandeputte <koen.vandeputte@ncentric.com>
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35362 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752928AbdDLQQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:16:07 -0400
Received: by mail-wm0-f47.google.com with SMTP id w64so92083364wma.0
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 09:16:06 -0700 (PDT)
In-Reply-To: <AM4PR0401MB2260310769B1983FAE5D7814FF010@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 9, 2017 at 6:42 PM, Andy Duan <fugang.duan@nxp.com> wrote:
> From: Tim Harvey <tharvey@gateworks.com> Sent: Friday, April 07, 2017 10:47 PM
>>To: netdev <netdev@vger.kernel.org>
>>Cc: Fabio Estevam <fabio.estevam@nxp.com>; Lucas Stach
>><l.stach@pengutronix.de>; Andy Duan <fugang.duan@nxp.com>; Koen
>>Vandeputte <koen.vandeputte@ncentric.com>
>>Subject: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
>>
>>Greetings,
>>
>>I've had a couple of users report that they are getting occasional link drops
>>when using IMX6 FEC on our boards which are using a Marvell
>>88E1510 PHY:
>>
>>[ 9348.474418] fec 2188000.ethernet eth0: MDIO read timeout [ 9350.478804]
>>fec 2188000.ethernet eth0: Link is Down
>>
>>If they bring the interface back up it works fine.
>>
>>The most recent version of Linux they have tested and seen this on is
>>v4.9 with CONFIG_MARVELL_PHY=y
>>
>>Has anyone else run into this or know what the issue could be? Should there
>>be any retries at the MDIO level or above?
>>
>>Regards,
>>
>>Tim
>
> Pls keep ipg clock always on and try it.
> In general, MDIO timeout maybe caused by ipg clock off and mii interrupt lost.
>

Andy,

Sounds like what Andrew was talking about. In this case suspend/resume
is not being used. Is there any other way IPG can get turned off that
I should be looking at?

Tim

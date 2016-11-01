From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: Why does tcp collapse behavior depend on nr_frags?
Date: Tue, 1 Nov 2016 08:15:15 +0000
Message-ID: <VI1PR0502MB29577BA8C670D1379CC4F1B7D4A10@VI1PR0502MB2957.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        tls-fpga-sw-dev <tls-fpga-sw-dev@mellanox.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:11136
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1168041AbcKAIsX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 04:48:23 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I've notice that tcp_can_collapse() returns false if skb_shinfo(skb)->nr_fr=
ags !=3D 0.
Is there a reason why we want to base the collapse decision in retransmissi=
on on whether
the data is located in a frag or the linear part?

The relevant commit is
	 tcp: collapse more than two on retransmission  ('4a17fc3add594fcc1c778e93=
a95b6ecf47f630e5')

Thanks,
Ilya

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 01/10] net/mlx4_core: Make each VF manage its own
 mac table
Date: Mon, 28 Nov 2016 15:37:44 +0000
Message-ID: <BL2PR07MB23062C0CE3A462FAE9B9A5EA8D8A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
 <1480261877-19720-2-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Gal Pressman <galp@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0088.outbound.protection.outlook.com ([104.47.34.88]:9680
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932718AbcK1Phq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 10:37:46 -0500
In-Reply-To: <1480261877-19720-2-git-send-email-tariqt@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Each VF can catch up to the max number of MACs in the MAC table (128) on
> the base of "first asks first gets".
> The VF should know the total free number of MACs from the PF.

While this might be a reasonable default policy given the alternatives
[or more precisely, the lack of ability for hyper-user to configure such],
it still sounds a bit crude - a user would have an available MAC only if
other users were kind enough not to consume all of them?

Have you thought of adding some configurable method through which
this could be controlled?

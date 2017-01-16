From: Daniel Jurgens <danielj@mellanox.com>
Subject: Re: [PATCH net-next 3/9] net/mlx4_core: Set EQ affinity hint to local
 NUMA CPUs
Date: Mon, 16 Jan 2017 21:54:36 +0000
Message-ID: <VI1PR0501MB2429F11A34431293F2D0C327C47D0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
 <1484587805-12666-4-git-send-email-tariqt@mellanox.com>
 <CAJ3xEMiGQHV1Qc0aW43SJaNO7X5TRLdYRaZgEiA6099vbBAAXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0061.outbound.protection.outlook.com ([104.47.2.61]:52101
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750996AbdAPVyk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 16:54:40 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/16/2017 3:44 PM, Or Gerlitz wrote:=0A=
> On Mon, Jan 16, 2017 at 7:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote=
:=0A=
>> From: Daniel Jurgens <danielj@mellanox.com>=0A=
>>=0A=
>> Use CPUs on the close NUMA when setting the EQ affinity hints.=0A=
> Dan, are we sure there are no down-sides for always doing this? this=0A=
> code is probably there for many years and we're introducing here new=0A=
> behaviour to potentially to many Ms installs when they get distro=0A=
> update that includes this patch.=0A=
>=0A=
I don't see a downside, this just favors using the node local CPUs before o=
thers.  I don't understand your 2nd sentence there.  "Ms installs"?=0A=
=0A=

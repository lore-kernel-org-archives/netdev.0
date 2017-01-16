From: Daniel Jurgens <danielj@mellanox.com>
Subject: Re: [PATCH net-next 3/9] net/mlx4_core: Set EQ affinity hint to local
 NUMA CPUs
Date: Mon, 16 Jan 2017 22:21:54 +0000
Message-ID: <VI1PR0501MB2429A6F8FDBD6DC9E835BE66C47D0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
 <1484587805-12666-4-git-send-email-tariqt@mellanox.com>
 <CAJ3xEMiGQHV1Qc0aW43SJaNO7X5TRLdYRaZgEiA6099vbBAAXw@mail.gmail.com>
 <VI1PR0501MB2429F11A34431293F2D0C327C47D0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
 <CAJ3xEMjGv8xm7vOgASd0CvpS9uQFLv8tT_n7aqsuoB7eTUAZUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "Eran Ben Elisha" <eranbe@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10042.outbound.protection.outlook.com ([40.107.1.42]:35324
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750858AbdAPWWA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 17:22:00 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/16/2017 3:59 PM, Or Gerlitz wrote:=0A=
> On Mon, Jan 16, 2017 at 11:54 PM, Daniel Jurgens <danielj@mellanox.com> w=
rote:=0A=
>> On 1/16/2017 3:44 PM, Or Gerlitz wrote:=0A=
>>> On Mon, Jan 16, 2017 at 7:29 PM, Tariq Toukan <tariqt@mellanox.com> wro=
te:=0A=
>>>> From: Daniel Jurgens <danielj@mellanox.com>=0A=
>>>>=0A=
>>>> Use CPUs on the close NUMA when setting the EQ affinity hints.=0A=
>>> Dan, are we sure there are no down-sides for always doing this? this=0A=
>>> code is probably there for many years and we're introducing here new=0A=
>>> behaviour to potentially to many Ms installs when they get distro=0A=
>>> update that includes this patch.=0A=
>=0A=
>> I don't see a downside, this just favors using the node local CPUs befor=
e others.=0A=
> OK, so this just favors before others and not limits (not in front of=0A=
> the code now)? would be good to improve the change log and make this=0A=
> clear.=0A=
Right, doesn't limit.  Just favors the local node.  I can work with Tariq t=
o update the commit message if you think it necessary.=0A=

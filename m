From: Daniel Jurgens <danielj@mellanox.com>
Subject: Re: [net-next 2/8] net/mlx5: Configure cache line size for start and
 end padding
Date: Thu, 2 Feb 2017 14:47:14 +0000
Message-ID: <VI1PR0501MB2429398983643A6387BE91D0C44C0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
 <20170131205843.23235-3-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BC4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0042.outbound.protection.outlook.com ([104.47.0.42]:6800
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751107AbdBBOre (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 09:47:34 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/1/2017 5:12 AM, David Laight wrote:=0A=
> From: Saeed Mahameed=0A=
>> Sent: 31 January 2017 20:59=0A=
>> From: Daniel Jurgens <danielj@mellanox.com>=0A=
>>=0A=
>> There is a hardware feature that will pad the start or end of a DMA to=
=0A=
>> be cache line aligned to avoid RMWs on the last cache line. The default=
=0A=
>> cache line size setting for this feature is 64B. This change configures=
=0A=
>> the hardware to use 128B alignment on systems with 128B cache lines.=0A=
> What guarantees that the extra bytes are actually inside the receive skb'=
s=0A=
> head and tail room?=0A=
>=0A=
> 	David=0A=
>=0A=
>=0A=
The hardware won't over write the length of the posted buffer.  This featur=
e is already enabled and defaults to 64B stride, this patch just configures=
 it properly for 128B cache line sizes.=0A=
=0A=
Thanks for reviewing it.=0A=
=0A=
Dan=0A=
=0A=

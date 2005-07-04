From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Tue, 05 Jul 2005 00:47:56 +0200
Message-ID: <42C9BC9C.9070700@cosmosbay.com>
References: <42B982D4.9040704@cosmosbay.com>	<1119467012.5325.15.camel@rh4>	<42C9A884.1030906@cosmosbay.com> <20050704.142604.18592223.davem@davemloft.net> <42C9AC97.1020902@cosmosbay.com> <42C9B8DB.7020403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42C9B8DB.7020403@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
>
>=20
> Oops, I forgot to tell you I applied the patch  : [TG3]: Eliminate all=20
> hw IRQ handler spinlocks.
> (Date: Fri, 03 Jun 2005 12:25:58 -0700 (PDT))
>=20
> Maybe I should revert to stock 2.6.12 tg3 driver ?
>=20
> Eric
>=20
>=20

Oh well, I checked 2.6.13-rc1 and it contains this line in tg3_netif_stop=
() :

+   tp->dev->trans_start =3D jiffies; /* prevent tx timeout */

So I am trying driver 3.32 June 24, 2005, included in 2.6.13-rc1

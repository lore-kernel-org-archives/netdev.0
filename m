From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] /proc/net/stat/rt_cache has a wrong header
Date: Fri, 18 Mar 2005 18:26:00 +0100
Message-ID: <423B0F28.3040508@cosmosbay.com>
References: <4238C388.5040303@cosmosbay.com>	<423AC418.6080903@cosmosbay.com> <20050318085056.0869394b@dxpl.pdx.osdl.net> <423B0C58.10709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>, acme@conectiva.com.br,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <423B0C58.10709@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :

> AFAIK the old stat file (/proc/net/rt_cache_acct) was OK.
>=20
> During the conversion to /proc/net/stat/rt_cache done in late 2.6.XX=20
> version, a bug was introduced, in kernel and also in iproute2.
>=20
> The API if fine, and my patch doesnt change it.
>=20
> Eric
>=20
>=20

I should give more explanations about the bug :

Each line contains 17 fields.

But the header contains only 16 fields, one column (in_slow_mc, the 4th f=
ield) was forgotten.

Thus rtstat (from last iproute2) gives wrong information starting at 4th =
column.

Eric

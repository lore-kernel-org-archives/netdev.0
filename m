From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] /proc/net/stat/rt_cache has a wrong header
Date: Fri, 18 Mar 2005 18:14:00 +0100
Message-ID: <423B0C58.10709@cosmosbay.com>
References: <4238C388.5040303@cosmosbay.com>	<423AC418.6080903@cosmosbay.com> <20050318085056.0869394b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: acme@conectiva.com.br, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050318085056.0869394b@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> On Fri, 18 Mar 2005 13:05:44 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>=20
>>Hello
>>
>>The header of /proc/net/stat/rt_cache misses the 'in_slow_mc' field.
>>This patch adds it.
>=20
>=20
> Current iproute2 tools adapt to additional fields, but wouldn't this be=
 breaking
> the API for other tools? (if any)
>=20
>=20

AFAIK the old stat file (/proc/net/rt_cache_acct) was OK.

During the conversion to /proc/net/stat/rt_cache done in late 2.6.XX vers=
ion, a bug was introduced, in kernel and also in iproute2.

The API if fine, and my patch doesnt change it.

Eric

From: Patrick McHardy <kaber@trash.net>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: Sat, 26 Mar 2005 02:23:38 +0100
Message-ID: <4244B99A.9080507@trash.net>
References: <1111795927.1089.749.camel@jzny.localdomain> <20050326003058.GA22930@gondor.apana.org.au> <1111798470.1090.774.camel@jzny.localdomain> <20050326005855.GA23533@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326005855.GA23533@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Mar 25, 2005 at 07:54:31PM -0500, jamal wrote:
>=20
>>It seems that we dont support any acquires from userspace to kernel
>=20
>=20
> I haven't checked af_key but netlink does support that.  All you have
> to do is send messages to the correct multicast group.
>=20
> Of course whether any of the KMs actually deal with it is a different
> story :)

af_key implements the second part of RFC2367 =A73.1.6, canceling
an acquire request by sending an acquire message to the kernel with
the same sequence number as the initial acquire request. It doesn't
support the third part, acting as KM for userspace.

Regards
Patrick

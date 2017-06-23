From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v3 1/6] vxlan: refactor verification
 and application of configuration
Date: Fri, 23 Jun 2017 12:13:46 +0200
Message-ID: <113c3fe1-f490-d92d-2b4a-69b7115d8115@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
	<6e2c8bb77be42834f1da5a3ca79f5e455574a136.1497825555.git.mschiffer@universe-factory.net>
	<20170623105220.18561f34@griffin>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1617047487724823029=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170623105220.18561f34@griffin>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============1617047487724823029==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="kX56mNhitti5XKHKoPEP4U8CnxwXjNWHG"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kX56mNhitti5XKHKoPEP4U8CnxwXjNWHG
Content-Type: multipart/mixed; boundary="gdhcD84BvwBeUEEsOuaHekIgx323jI82F";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org,
 aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <113c3fe1-f490-d92d-2b4a-69b7115d8115-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v3 1/6] vxlan: refactor verification and
 application of configuration
References: <cover.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <6e2c8bb77be42834f1da5a3ca79f5e455574a136.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <20170623105220.18561f34@griffin>
In-Reply-To: <20170623105220.18561f34@griffin>

--gdhcD84BvwBeUEEsOuaHekIgx323jI82F
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 06/23/2017 10:52 AM, Jiri Benc wrote:
> This patchset looks good overall (would send my Acked-by for most of
> this but I'm late).
>=20
> On Mon, 19 Jun 2017 10:03:55 +0200, Matthias Schiffer wrote:
>> Log messages in these
>> functions are removed, as it is generally unexpected to find error out=
put
>> for netlink requests in the kernel log. Userspace should be able to ha=
ndle
>> errors based on the error codes returned via netlink just fine.
>=20
> However, this is not really true. It's impossible to find out what went=

> wrong when you use e.g. iproute2 to configure a vxlan link.
>=20
> We really need to convert the kernel log messages to the extended
> netlink errors. Since you removed them prematurely, could you please
> work on that?
>=20
> Thanks,
>=20
>  Jiri
>=20

I was told the extended netlink error facilities were not ready yet, has
that changed since the last release?

Off the top of my head, I can't think of any other setting I can do with
iproute2 that will write its errors in the kernel log; but there are quit=
e
a lot settings that will just return a very unspecific error code. Isn't =
it
more common for the userspace tool to handle diagnostics in such cases?

Anyways, I will gladly work on improving the error handling if someone ca=
n
give me a pointer how these extended netlink errors are used.

Matthias


--gdhcD84BvwBeUEEsOuaHekIgx323jI82F--

--kX56mNhitti5XKHKoPEP4U8CnxwXjNWHG--

--===============1617047487724823029==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1617047487724823029==--

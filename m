From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 6/6] vxlan: allow multiple VXLANs
 with same VNI for IPv6 link-local addresses
Date: Sun, 16 Apr 2017 17:15:42 +0200
Message-ID: <3c054ae3-ec68-ab20-0928-81e313a53cde@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
	<95533e3ca4958ba2eca3efcc661713638feea220.1492187126.git.mschiffer@universe-factory.net>
	<20170414103830.111a24a8@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0430265894201160579=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170414103830.111a24a8@xeon-e3>
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
--===============0430265894201160579==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="JuXnqjarqDiS4BpaQrhbesiIPn8wECC0V"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JuXnqjarqDiS4BpaQrhbesiIPn8wECC0V
Content-Type: multipart/mixed; boundary="e9sgaWALmGCrRmhoEjqbHEULBeiMTohxm";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 pshelar-LZ6Gd1LRuIk@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <3c054ae3-ec68-ab20-0928-81e313a53cde-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 6/6] vxlan: allow multiple VXLANs with same
 VNI for IPv6 link-local addresses
References: <cover.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <95533e3ca4958ba2eca3efcc661713638feea220.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <20170414103830.111a24a8@xeon-e3>
In-Reply-To: <20170414103830.111a24a8@xeon-e3>

--e9sgaWALmGCrRmhoEjqbHEULBeiMTohxm
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 04/14/2017 07:38 PM, Stephen Hemminger wrote:
> On Fri, 14 Apr 2017 18:44:46 +0200
> Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org> wrote:
>=20
>> As link-local addresses are only valid for a single interface, we can =
allow
>> to use the same VNI for multiple independent VXLANs, as long as the us=
ed
>> interfaces are distinct. This way, VXLANs can always be used as a drop=
-in
>> replacement for VLANs with greater ID space.
>>
>> This also extends VNI lookup to respect the ifindex when link-local IP=
v6
>> addresses are used, so using the same VNI on multiple interfaces can
>> actually work.
>>
>> Signed-off-by: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
>=20
> Why does this have to be IPv6 specific?

I'm not familar with IPv4 link-local addresses and how route lookup works=

for them. vxlan_get_route() sets flowi4_oif to the outgoing interface; do=
es
__ip_route_output_key_hash() do the right thing for link-local addresses
when such addresses are used on multiple interfaces? I see some special
casing for multicast destinations, but none for link-local ones.

>=20
> What about the case where VXLAN is not bound to an interface?
> If that is used then that could be a problem.
>=20

With patch 4/6, link-local IPv6 addresses can't be configured without an
interface anymore.

Matthias


--e9sgaWALmGCrRmhoEjqbHEULBeiMTohxm--

--JuXnqjarqDiS4BpaQrhbesiIPn8wECC0V--

--===============0430265894201160579==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0430265894201160579==--

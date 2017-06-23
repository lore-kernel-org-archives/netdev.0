From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v3 1/6] vxlan: refactor verification
 and application of configuration
Date: Fri, 23 Jun 2017 14:02:26 +0200
Message-ID: <a250dc2b-1249-2cfe-6f39-06b7f0874f59@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
	<6e2c8bb77be42834f1da5a3ca79f5e455574a136.1497825555.git.mschiffer@universe-factory.net>
	<20170623105220.18561f34@griffin>
	<113c3fe1-f490-d92d-2b4a-69b7115d8115@universe-factory.net>
	<1498213402.2595.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5749599592614694143=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1498213402.2595.3.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
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
--===============5749599592614694143==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="IttUlBsbNaBWudkn5MHwd1tc93gnCehiE"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IttUlBsbNaBWudkn5MHwd1tc93gnCehiE
Content-Type: multipart/mixed; boundary="UW794PxvdjwpKjDQoiv4f39VMx3hgoMiD";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org,
 aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <a250dc2b-1249-2cfe-6f39-06b7f0874f59-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v3 1/6] vxlan: refactor verification and
 application of configuration
References: <cover.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <6e2c8bb77be42834f1da5a3ca79f5e455574a136.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <20170623105220.18561f34@griffin>
 <113c3fe1-f490-d92d-2b4a-69b7115d8115-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <1498213402.2595.3.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1498213402.2595.3.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

--UW794PxvdjwpKjDQoiv4f39VMx3hgoMiD
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 06/23/2017 12:23 PM, Johannes Berg wrote:
> On Fri, 2017-06-23 at 12:13 +0200, Matthias Schiffer wrote:
>>
>> I was told the extended netlink error facilities were not ready yet,
>> has that changed since the last release?
>=20
> Yes, the facility is in the kernel tree now.
>=20
>> Anyways, I will gladly work on improving the error handling if
>> someone can give me a pointer how these extended netlink errors are
>> used.
>=20
> Just grep for 'netlink_ext_ack' :)
>=20
> johannes
>=20

Thanks for the hint.

It seems though that rtnl_link_ops.newlink/changelink don't allow passing=

the extack yet... how do we proceed here? Treewide change (maybe by someo=
ne
who knows their Coccinelle-fu?), or would the introduction of new version=
s
of the newlink and changelink fields be more acceptable, so drivers can b=
e
moved to the new API one by one?

Matthias


--UW794PxvdjwpKjDQoiv4f39VMx3hgoMiD--

--IttUlBsbNaBWudkn5MHwd1tc93gnCehiE--

--===============5749599592614694143==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============5749599592614694143==--

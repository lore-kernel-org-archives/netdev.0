From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/6] vxlan: check valid
 combinations of address scopes
Date: Sun, 16 Apr 2017 17:03:53 +0200
Message-ID: <d401b6c7-357a-1e1c-13bd-64e9af951971@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
	<49cd788f13c2cd3f6a42f34c219c9511cc1f9cec.1492187126.git.mschiffer@universe-factory.net>
	<20170414103604.61ecffa9@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5487935961027068258=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170414103604.61ecffa9@xeon-e3>
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
--===============5487935961027068258==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="VbTrHkq6VFJqm8MjCDLbKmikOxfAPlAqI"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VbTrHkq6VFJqm8MjCDLbKmikOxfAPlAqI
Content-Type: multipart/mixed; boundary="eLgAFfxR30hUrVmSvktLso4HpDfTCLXtN";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 pshelar-LZ6Gd1LRuIk@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <d401b6c7-357a-1e1c-13bd-64e9af951971-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/6] vxlan: check valid combinations of
 address scopes
References: <cover.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <49cd788f13c2cd3f6a42f34c219c9511cc1f9cec.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <20170414103604.61ecffa9@xeon-e3>
In-Reply-To: <20170414103604.61ecffa9@xeon-e3>

--eLgAFfxR30hUrVmSvktLso4HpDfTCLXtN
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 04/14/2017 07:36 PM, Stephen Hemminger wrote:
> On Fri, 14 Apr 2017 18:44:44 +0200
> Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org> wrote:
>=20
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 07f89b037681..95a71546e8f2 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -2881,11 +2881,39 @@ static int vxlan_config_validate(struct net *s=
rc_net, struct vxlan_config *conf,
>>  	if (conf->saddr.sa.sa_family !=3D conf->remote_ip.sa.sa_family)
>>  		return -EINVAL;
>> =20
>> +	if (vxlan_addr_multicast(&conf->saddr))
>> +		return -EINVAL;
>> +
>>  	if (conf->saddr.sa.sa_family =3D=3D AF_INET6) {
>>  		if (!IS_ENABLED(CONFIG_IPV6))
>>  			return -EPFNOSUPPORT;
>>  		use_ipv6 =3D true;
>>  		conf->flags |=3D VXLAN_F_IPV6;
>> +
>> +		if (!(conf->flags & VXLAN_F_COLLECT_METADATA)) {
>> +			int local_type =3D
>> +				ipv6_addr_type(&conf->saddr.sin6.sin6_addr);
>> +			int remote_type =3D
>> +				ipv6_addr_type(&conf->remote_ip.sin6.sin6_addr);
>> +
>> +			if (local_type & IPV6_ADDR_LINKLOCAL) {
>> +				if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
>> +				    (remote_type !=3D IPV6_ADDR_ANY)) {
>> +					pr_info("invalid combination of address scopes\n");
>=20
> It is always helpful to include device if possible in error message.
> 					netdev_notice(old->dev, " invalid combination of address scopes\n"=
);

That makes sense, I'll change it in v3.

> Also vxlan is good candidate for extended netlink error reporting.

Can you point me to a piece of code that does this? Unless you insist, I
wouldn't do it in this patchset, but I might implement the extended error=

reporting later.

Matthias



--eLgAFfxR30hUrVmSvktLso4HpDfTCLXtN--

--VbTrHkq6VFJqm8MjCDLbKmikOxfAPlAqI--

--===============5487935961027068258==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============5487935961027068258==--

From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/6] vxlan: check valid
 combinations of address scopes
Date: Sun, 16 Apr 2017 16:57:44 +0200
Message-ID: <dcf7f3b9-09ff-4072-9dd6-3dc33932cac1@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
	<49cd788f13c2cd3f6a42f34c219c9511cc1f9cec.1492187126.git.mschiffer@universe-factory.net>
	<0dd0812f-41d7-f4d8-2b40-0ff5b4553cf5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2133677749878182184=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <0dd0812f-41d7-f4d8-2b40-0ff5b4553cf5-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
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
--===============2133677749878182184==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="EkaWXiH3ekGngIcIsdf2F77k0c7QVA7AT"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EkaWXiH3ekGngIcIsdf2F77k0c7QVA7AT
Content-Type: multipart/mixed; boundary="jmA7PEKdSuTJLNReH16wKg5jVo5V2OT4t";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 pshelar-LZ6Gd1LRuIk@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <dcf7f3b9-09ff-4072-9dd6-3dc33932cac1-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/6] vxlan: check valid combinations of
 address scopes
References: <cover.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <49cd788f13c2cd3f6a42f34c219c9511cc1f9cec.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <0dd0812f-41d7-f4d8-2b40-0ff5b4553cf5-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
In-Reply-To: <0dd0812f-41d7-f4d8-2b40-0ff5b4553cf5-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

--jmA7PEKdSuTJLNReH16wKg5jVo5V2OT4t
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 04/14/2017 07:27 PM, Sergei Shtylyov wrote:
> On 04/14/2017 07:44 PM, Matthias Schiffer wrote:
>=20
>> * Multicast addresses are never valid as local address
>> * Link-local IPv6 unicast addresses may only be used as remote when th=
e
>>   local address is link-local as well
>> * Don't allow link-local IPv6 local/remote addresses without interface=

>>
>> We also store in the flags field if link-local addresses are used for =
the
>> follow-up patches that actually make VXLAN over link-local IPv6 work.
>>
>> Signed-off-by: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
>> ---
>>
>> v2: was "vxlan: don't allow link-local IPv6 local/remote addresses wit=
hout
>> interface" before. v2 does a lot more checks and adds the
>> VXLAN_F_IPV6_LINKLOCAL flag.
>>
>>  drivers/net/vxlan.c | 35 +++++++++++++++++++++++++++++++++++
>>  include/net/vxlan.h |  2 ++
>>  2 files changed, 37 insertions(+)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 07f89b037681..95a71546e8f2 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -2881,11 +2881,39 @@ static int vxlan_config_validate(struct net
>> *src_net, struct vxlan_config *conf,
>>      if (conf->saddr.sa.sa_family !=3D conf->remote_ip.sa.sa_family)
>>          return -EINVAL;
>>
>> +    if (vxlan_addr_multicast(&conf->saddr))
>> +        return -EINVAL;
>> +
>>      if (conf->saddr.sa.sa_family =3D=3D AF_INET6) {
>>          if (!IS_ENABLED(CONFIG_IPV6))
>>              return -EPFNOSUPPORT;
>>          use_ipv6 =3D true;
>>          conf->flags |=3D VXLAN_F_IPV6;
>> +
>> +        if (!(conf->flags & VXLAN_F_COLLECT_METADATA)) {
>> +            int local_type =3D
>> +                ipv6_addr_type(&conf->saddr.sin6.sin6_addr);
>> +            int remote_type =3D
>> +                ipv6_addr_type(&conf->remote_ip.sin6.sin6_addr);
>> +
>> +            if (local_type & IPV6_ADDR_LINKLOCAL) {
>> +                if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
>> +                    (remote_type !=3D IPV6_ADDR_ANY)) {
>> +                    pr_info("invalid combination of address scopes\n"=
);
>=20
>    Maybe pr_err()?

Hmm, I mostly followed the style of the existing code, which uses pr_info=

for such messages. Also, these messages can be triggered by userspace, as=

they're diagnostics for the newlink/changelink operations; I'm not
convinced that their importance justifies pr_err().

Generally, it seems unusual to me to use the kernel log for configuration=

diagnostics at all; just removing the messages would be another option.
Stephen also mentioned "extended netlink error reporting", but I guess th=
at
can be done in another patchset.

Matthias


--jmA7PEKdSuTJLNReH16wKg5jVo5V2OT4t--

--EkaWXiH3ekGngIcIsdf2F77k0c7QVA7AT--

--===============2133677749878182184==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2133677749878182184==--

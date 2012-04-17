From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 00/12] add namespace support for netfilter protos
Date: Tue, 17 Apr 2012 18:12:52 +0800
Message-ID: <4F8D4224.7040100@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com> <20120417085209.GA2100@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120417085209.GA2100@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi pablo

=E4=BA=8E 2012=E5=B9=B404=E6=9C=8817=E6=97=A5 16:52, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> Hi Gao,
>=20
> On Tue, Apr 17, 2012 at 10:56:11AM +0800, Gao feng wrote:
>> Currently the sysctl of netfilter proto is not isolated, so when=20
>> changing proto's sysctl in container will cause the host's sysctl=20
>> be changed too. it's not expected.
>>
>> This patch set adds the namespace support for netfilter protos.
>>
>> impletement four pernet_operations to register sysctl,and disable=20
>> register sysctl when protos are registered.
>=20
> This indeed needs to be fixed, but this patchset has several
> deficiencies. I'll spot them in follow-up emails.
>=20
>> nf_conntrack_net_proto_ipv4_ops is used to register tcp4(compat),
>> udp4(compat),icmp(compat),ipv4(compat).
>> nf_conntrack_net_proto_ipv6_ops is used to register tcp6,udp6 and=20
>> icmpv6.
>> nf_conntrack_net_proto_sctp_ops is used to register sctp4(compat)=20
>> and sctp6.
>> nf_conntrack_net_proto_udplite_ops is used to register udplite4
>> and udplite6
>>
>> these operations will be registered when module be loaded.
>>
>> And this will break the cttimeout, because timeout_nlattr_to_obj
>> function use the orig timeout(such as tcp_timeouts) to set timeouts.
>>
>> I will fix this in my next patch.
>=20
> No way.

OK... I will fix all and resend the patch ;)

>=20
> You cannot leave the repository in broken / inconsistent state becaus=
e
> you are not making things good.
>=20
> Please, hang on until this patchset is fixed to send more patches.
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

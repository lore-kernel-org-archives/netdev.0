From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 16/17] netfilter: add namespace support for cttimeout
Date: Thu, 24 May 2012 09:04:10 +0800
Message-ID: <4FBD890A.2020500@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-17-git-send-email-gaofeng@cn.fujitsu.com> <20120523104110.GF2836@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120523104110.GF2836@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:41, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Mon, May 14, 2012 at 04:52:26PM +0800, Gao feng wrote:
>> add struct net as a param of ctnl_timeout.nlattr_to_obj,
>>
>> modify ctnl_timeout_parse_policy and cttimeout_new_timeout
>> to transmit struct net to nlattr_to_obj.
>=20
> Please, merge your patch 16 and 17 into one single patch.
>=20
>>  	unsigned int *timeouts =3D data;
>> =20
>> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter=
/nf_conntrack_proto_sctp.c
>> index 291cef4..a28f3c4 100644
>> --- a/net/netfilter/nf_conntrack_proto_sctp.c
>> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
>> @@ -562,7 +562,8 @@ static int sctp_nlattr_size(void)
>>  #include <linux/netfilter/nfnetlink.h>
>>  #include <linux/netfilter/nfnetlink_cttimeout.h>
>> =20
>> -static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[], void *da=
ta)
>> +static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
>> +				      struct net *net, void *data)
>=20
> The interface modification and the use of the new *net parameter
> should go together, ie. merge patch 16 and 17 :-).

got it,thanks ;)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

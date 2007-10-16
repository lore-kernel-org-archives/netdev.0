From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH 2/2] Interface group match - netfilter part
Date: Tue, 16 Oct 2007 11:46:24 +0200
Message-ID: <47148870.3010107@balabit.hu>
References: <1192521703479-git-send-email-panther@balabit.hu> <11925217031287-git-send-email-panther@balabit.hu> <11925217031728-git-send-email-panther@balabit.hu> <47147692.8070709@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47147692.8070709@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> +static int match(const struct sk_buff *skb,
>> +      const struct net_device *in,
>> +      const struct net_device *out,
>> +      const struct xt_match *match,
>> +      const void *matchinfo,
>> +      int offset,
>> +      unsigned int protoff,
>> +      int *hotdrop)
>> +{
>> +    const struct xt_ifgroup_info *info =3D matchinfo;
>> +
>> +    return ((in->ifgroup & info->mask) =3D=3D info->group) ^ info->=
invert;
>=20
> The input interface is only valid in PREROUTING, INPUT and FORWARD.
> Why don't you support output-interface matching?
>=20
It has no specific reason. I'll make it with the other changes you=20
wrote. I'll send the iptables patch at the same time.

--=20
Attila
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

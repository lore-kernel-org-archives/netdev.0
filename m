From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] net: ipv6: fallback to full lookup if table lookup is unsuitable
Date: Mon, 19 Sep 2016 22:27:32 +0200
Message-ID: <m3a8f3k53f.fsf@neo.luffy.cx>
References: <20160916125531.3486-1-vincent@bernat.im>
        <20160919.005857.553516799273302087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: dsa@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:42960 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751888AbcISU1h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 16:27:37 -0400
In-Reply-To: <20160919.005857.553516799273302087.davem@davemloft.net> (David
        Miller's message of "Mon, 19 Sep 2016 00:58:57 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 19 septembre 2016 06:58 CEST, David Miller <davem@davemloft.net>=
=C2=A0:

>> @@ -1808,6 +1808,30 @@ static struct rt6_info *ip6_nh_lookup_table(struc=
t net *net,
>>  	return rt;
>>  }
>>=20=20
>> +static int ip6_nh_valid(struct rt6_info *grt,
>> +			struct net_device **dev, struct inet6_dev **idev) {
>> +	int ret =3D 0;
>
> First, this is not formatted properly.  The openning brace should start
> on a new line.
>
> Second, please use "bool", "true", and "false" for the return value.

Noted for the next time. However, the v3 version of the patch doesn't
have the function anymore.
--=20
Avoid temporary variables.
            - The Elements of Programming Style (Kernighan & Plauger)

From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next 1/8] Introduce ife encapsulation module
Date: Thu, 10 Nov 2016 19:52:50 +0000
Message-ID: <AM3PR05MB0759D7525807B4A30A2AEF5BACB80@AM3PR05MB0759.eurprd05.prod.outlook.com>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
        <1478776988-5400-2-git-send-email-jiri@resnulli.us>
 <20161110.141731.1693686577994851858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>,
        "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0076.outbound.protection.outlook.com ([104.47.2.76]:63296
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933973AbcKJTwx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 14:52:53 -0500
In-Reply-To: <20161110.141731.1693686577994851858.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, November 10, 2016 9:18 PM
>To: jiri@resnulli.us
>Cc: netdev@vger.kernel.org; Yotam Gigi <yotamg@mellanox.com>; Ido Schimmel
><idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
><nogahf@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>;
>jhs@mojatatu.com; geert+renesas@glider.be; stephen@networkplumber.org;
>xiyou.wangcong@gmail.com; linux@roeck-us.net; roopa@cumulusnetworks.com
>Subject: Re: [patch net-next 1/8] Introduce ife encapsulation module
>
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu, 10 Nov 2016 12:23:01 +0100
>
>> +void *ife_encode(struct sk_buff *skb, u16 metalen)
>
>metalen is u16
>
>> +	metalen =3D htons(metalen);
>
>htons() returns be16.
>
>> +int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const vo=
id
>*dval)
>> +{
>> +	u32 *tlv =3D (u32 *) (skbdata);
> ...
>> +	*tlv =3D htonl(htlv);
>
>Similar situation here.

I will fix those and we will send a v2.

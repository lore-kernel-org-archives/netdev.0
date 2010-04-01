From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Thu, 01 Apr 2010 16:07:53 +0300
Message-ID: <4BB49AA9.1070900@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi>	 <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <1270127120.2229.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:13775 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650Ab0DANH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 09:07:56 -0400
Received: by ey-out-2122.google.com with SMTP id d26so76050eyd.19
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 06:07:55 -0700 (PDT)
In-Reply-To: <1270127120.2229.93.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 01 avril 2010 =C3=A0 15:52 +0300, Timo Teras a =C3=A9crit :
>> @@ -481,6 +482,7 @@ struct xfrm_policy {
>>  	atomic_t		refcnt;
>>  	struct timer_list	timer;
>> =20
>> +	struct flow_cache_entry_ops *fc_ops;
>>  	u32			priority;
>>  	u32			index;
>>  	struct xfrm_mark	mark;
> ...
>=20
>> +static struct flow_cache_entry_ops xfrm_policy_fc_ops __read_mostly=
 =3D {
>> +	.get =3D xfrm_policy_get_fce,
>> +	.check =3D xfrm_policy_check_fce,
>> +	.delete =3D xfrm_policy_delete_fce,
>> +};
>> =20
>=20
> Any particular reason these flow_cache_entry_ops are not const ?

Umm... No. I'll constify them. Thanks.

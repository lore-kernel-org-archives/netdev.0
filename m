From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH ipsec-next] xfrm: Do not parse 32bits compiled xfrm netlink
 msg on 64bits host
Date: Tue, 27 Jan 2015 15:44:36 +0800
Message-ID: <54C741E4.2000009@gmail.com>
References: <1422327262-6344-1-git-send-email-fan.du@intel.com> <20150126.233938.513240875461315013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fan.du@intel.com, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:54661 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757394AbbA0Hsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 02:48:41 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so16959670pad.1
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 23:48:41 -0800 (PST)
In-Reply-To: <20150126.233938.513240875461315013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B401=E6=9C=8827=E6=97=A5 15:39, David Miller =E5=86=
=99=E9=81=93:
> From: Fan Du <fan.du@intel.com>
> Date: Tue, 27 Jan 2015 10:54:22 +0800
>
>> @@ -2419,6 +2419,11 @@ static int xfrm_user_rcv_msg(struct sk_buff *=
skb, struct nlmsghdr *nlh)
>>   	const struct xfrm_link *link;
>>   	int type, err;
>>
>> +#ifdef CONFIG_COMPAT
>> +	if (is_compat_task())
>> +		return -EPERM;
>> +#endif
>> +
>
> This seems more like an unsupported operation rather then a permissio=
n
> problem.
>
how about *ENOTSUPP* ?

--=20
No zuo no die but I have to try.

From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : inet_ehash_secret should be __read_mostly and set
 only once
Date: Tue, 27 Mar 2007 23:03:06 +0200
Message-ID: <4609868A.5030103@cosmosbay.com>
References: <20070327121343.395a57e5.dada1@cosmosbay.com>
 <20070327.135338.77404865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:33295 "EHLO smTp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934225AbXC0VDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 17:03:22 -0400
Received: from [192.168.30.10] ([86.66.237.74]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0JFK00IDMYH55S82@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Tue, 27 Mar 2007 23:03:06 +0200 (CEST)
In-reply-to: <20070327.135338.77404865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 27 Mar 2007 12:13:43 +0200
>=20
>> Hi David
>>
>> Please find this patch against net-2.6.22
>>
>> Thank you
>>
>> [PATCH] NET : inet_ehash_secret should be __read_mostly and set only=
 once
>>
>> There is a very tiny probability that build_ehash_secret() is called=
 at the same time by different CPUS.
>>
>> Also, using __read_mostly is a must for inet_ehash_secret
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Applied, but I left out this totally unrelated code formatting
> change in your patch:
>=20
>> @@ -684,7 +694,8 @@ int inet_sendmsg(struct kiocb *iocb, str
>>  }
>> =20
>> =20
>> -static ssize_t inet_sendpage(struct socket *sock, struct page *page=
, int offset, size_t size, int flags)
>> +static ssize_t inet_sendpage(struct socket *sock, struct page *page=
, int offset,
>> +	size_t size, int flags)
>>  {
>>  	struct sock *sk =3D sock->sk;
>> =20

Well... just a minor change to reduce length of this too long line...


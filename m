From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net: ipv6: change %8s to %s for seq_printf of if6_seq_stop
Date: Tue, 06 Nov 2012 09:26:50 +0800
Message-ID: <5098675A.7080602@asianux.com>
References: <5097A030.5030209@asianux.com>  <50986442.80009@asianux.com> <1352164902.2747.284.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:53868 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186Ab2KFBZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 20:25:51 -0500
In-Reply-To: <1352164902.2747.284.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8806=E6=97=A5 09:21, Eric Dumazet =E5=86=
=99=E9=81=93:
>> @@ -3281,7 +3281,7 @@ static void if6_seq_stop(struct seq_file *seq,
>> void *v)
>>  static int if6_seq_show(struct seq_file *seq, void *v)
>>  {
>>  	struct inet6_ifaddr *ifp =3D (struct inet6_ifaddr *)v;
>> -	seq_printf(seq, "%pi6 %02x %02x %02x %02x %8s\n",
>> +	seq_printf(seq, "%pi6 %02x %02x %02x %02x %s\n",
>>  		   &ifp->addr,
>>  		   ifp->idev->dev->ifindex,
>>  		   ifp->prefix_len,
>=20
> This is a change in if6_seq_show(), not if6_seq_stop() as mentioned i=
n
> patch title.
>=20

  sorry again,

  I will send it again (although it will almost be spam).


--=20
Chen Gang

Asianux Corporation

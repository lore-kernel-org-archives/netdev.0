From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH] bonding: add the sysfs interface to see RLB hash table
Date: Wed, 01 Dec 2010 14:03:35 +0900
Message-ID: <4CF5D727.3090905@jp.fujitsu.com>
References: <4CF4CB85.4010708@jp.fujitsu.com> <1291111829.2904.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:57630 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab0LAFDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 00:03:53 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB153m7h003421
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Wed, 1 Dec 2010 14:03:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59B6345DE5C
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:03:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41C7445DE5B
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:03:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E2B11DB8037
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:03:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA5C1E08003
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:03:47 +0900 (JST)
In-Reply-To: <1291111829.2904.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(2010/11/30 19:10), Eric Dumazet wrote:
> Le mardi 30 novembre 2010 =C3=A0 19:01 +0900, Taku Izumi a =C3=A9crit=
 :

>> +	hash_index =3D bond_info->rx_hashtbl_head;
>> +	for (; hash_index !=3D RLB_NULL_INDEX; hash_index =3D client_info-=
>next) {
>> +		client_info =3D&(bond_info->rx_hashtbl[hash_index]);
>> +
>> +		count +=3D sprintf(buf + count,
>> +			"%3d.%3d.%3d.%3d %3d.%3d.%3d.%3d "
>> +			"%02x:%02x:%02x:%02x:%02x:%02x %s\n",
>=20
>=20
> Oh well, I guess you dont read Joe patches on netdev ;)
>=20
> Please take a look at %pI4 and %pM
>=20
> sprintf(buf + count, "%pI4 %pI4 %pM %s\n", ...)

 Thank you for your advice. I've become a little wiser..

Taku Izumi <izumi.taku@jp.fujitsu.com>


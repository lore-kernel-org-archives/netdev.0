From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next 1/2 RESEND v3] net: use NETIF_F_ALL_TSO for vlan
 features
Date: Thu, 12 May 2011 17:54:03 +0800
Message-ID: <4DCBAE3B.3070201@cn.fujitsu.com>
References: <4DCA2B86.9030205@cn.fujitsu.com> <4DCABABB.9040001@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	leedom@chelsio.com
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58230 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755580Ab1ELJyI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 05:54:08 -0400
In-Reply-To: <4DCABABB.9040001@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dimitris Michailidis wrote, at 2011=E5=B9=B405=E6=9C=8812=E6=97=A5 00:3=
5:
> On 05/10/2011 11:24 PM, Shan Wei wrote:
>> As Dimitris Michailidis suggested, use NETIF_F_ALL_TSO for vlan_feat=
ures,
>> which is a mask, but not hw_features.
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>=20
> While these changes aren't wrong I don't see a good reason to make th=
em.  I am also curious why you're changing only these three drivers.

A personal reason to quickly know what device supports ALL TSO,
not to search one by one. :;)

TSO offloads are assigned directly in these three drivers.
Other drivers set vlan_features as hw_features, or set TSO offloads aft=
er doing some check.

--=20
Best Regards
-----
Shan Wei

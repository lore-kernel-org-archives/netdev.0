From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 14:36:47 +0800
Message-ID: <4E9E6FFF.80802@cn.fujitsu.com>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>		 <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		 <4E9E2929.7070701@cn.fujitsu.com>	 <1318996187.19139.8.camel@edumazet-laptop>	 <4E9E5E1C.5020603@cn.fujitsu.com> <1319003231.16303.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61951 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab1JSGgT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 02:36:19 -0400
In-Reply-To: <1319003231.16303.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011.10.19 13:47, Eric Dumazet wrote:
> Le mercredi 19 octobre 2011 =C3=A0 13:20 +0800, Gao feng a =C3=A9crit=
 :
>=20
>> In orig ip_rt_frag_need,
>> zero can be return only when pmtu(get from icmp packet) is zero and =
peer is NULL.
>> in this case,raw_icmp_error will not be call too.this is valid??
>=20
> I dont know, tell me.
>=20
> I am afraid you're adding a possible regression here.
>=20
> pmtu from icmp_packet is not zero in the common case.
>=20
>=20

AS raw socket is special,I think it's should call raw_icmp_error even t=
he icmp packet is invalid.
if I am right,I think it's another BUG.

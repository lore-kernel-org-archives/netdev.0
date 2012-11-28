From: Chen Gang <gang.chen@asianux.com>
Subject: Re: Fwd: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name
 in seq_printf of rt6_info_route
Date: Wed, 28 Nov 2012 13:54:53 +0800
Message-ID: <50B5A72D.6070107@asianux.com>
References: <50ADE447.8030300@asianux.com> <50AEEF08.4000707@asianux.com> <50B430B5.1080700@gmail.com> <50B43F12.1090709@asianux.com> <50B44563.8060905@asianux.com> <50B45265.9070303@asianux.com> <50B4551C.6030505@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:17476 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2K1FyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 00:54:01 -0500
In-Reply-To: <50B4551C.6030505@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


completion: "8 right alignment should not belong to os api level"
  for api, we need keep as fewer contents as we can.
  for output format api: "contents"+"topology"+"separator mark"+"space =
redundancy" are enough.
  so "8 right alignment" should not belong to api level (it only belong=
s to "User Experience").


  "User Experience" is most likely 'beautiful' !!

  !-)


gchen.


=D3=DA 2012=C4=EA11=D4=C227=C8=D5 13:52, Chen Gang =D0=B4=B5=C0:
> =D3=DA 2012=C4=EA11=D4=C227=C8=D5 13:40, Chen Gang =D0=B4=B5=C0:
>>
>> and now, I think:
>>   A) both input and output through /proc/* are for os api level.
>>   B) but both %8s and %s do not change the output interface format (=
including contents, topology, separator mark, space redundancy).
>>   C) so it is belong to 'User Experience', not belong to os api.
>>
>>   welcome any another members to giving suggestions and completions.
>>
>>   thanks.
>>
>>   :-)
>>
>=20
>   completion: 8 right alignment is not belong to interface format.
>     if it was belong to interface format,
>     it would cause correctness issue (the name len may be larger than=
 8).
>     so if "8 right alignment" is belong to os api, it means the api i=
s not correct, need change.
>=20
>   :-)
>=20


--=20
Chen Gang

Asianux Corporation

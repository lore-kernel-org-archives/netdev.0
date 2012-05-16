From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Wed, 16 May 2012 10:59:46 +0800
Message-ID: <4FB31822.9060602@cn.fujitsu.com>
References: <20120215104021.GC31660@secunet.com> <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com> <20120514130528.GA24733@secunet.com> <4FB1D11A.4040206@cn.fujitsu.com> <20120515114840.GC24733@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, lw@cn.fujitsu.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:20730 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S966510Ab2EPC7T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 22:59:19 -0400
In-Reply-To: <20120515114840.GC24733@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8815=E6=97=A5 19:48, Steffen Klassert =E5=
=86=99=E9=81=93:
> On Tue, May 15, 2012 at 11:44:26AM +0800, Gao feng wrote:
>>
>> how about add a function pointer append_data to the struct rt6_info?
>> so we can just call rt->append_data in ip6_append_data without consi=
de
>> witch mode it is.
>>
>=20
> If you want to use a function pointer, it should go to stuct xfrm_mod=
e.
> That's where the IPsec mode dependent functions reside.
>=20

Yes,I will do it.

> A side note, I'll be off for three weeks starting from tomorrow.
> I'll have no E-mail access most of the time, so I'll probaply not
> respond for the next three weeks.

thanks for your response.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

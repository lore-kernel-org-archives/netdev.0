From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Tue, 20 Mar 2012 09:09:02 +0800
Message-ID: <4F67D8AE.2070602@cn.fujitsu.com>
References: <1331888235-10368-1-git-send-email-gaofeng@cn.fujitsu.com> <20120319080220.GA29891@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41966 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755914Ab2CTBIg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 21:08:36 -0400
In-Reply-To: <20120319080220.GA29891@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B403=E6=9C=8819=E6=97=A5 16:02, Steffen Klassert =E5=
=86=99=E9=81=93:
> On Fri, Mar 16, 2012 at 04:57:15PM +0800, Gao feng wrote:
>> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem=
)
>> In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdr=
len)
>> the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrle=
n at last
>> This will make fraggap>0 in next "while cycle",and cause the size of=
 skb incorrent
>=20
> Good catch!
>=20
>>
>> Call skb_pull reduce skb->len before next "while cycle"
>=20
> I think it would be better to just reserve headroom for
> dst_exthdrlen instead of adding and removing data to/from
> the skb.
>=20

Hi steffen & David:

Thanks for your comment.
Agree with you,I will send v2 patch.

From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [2.6 PATCH] IPV6: Check length of optval provided by user in
 setsockopt()
Date: Mon, 31 Mar 2008 18:46:25 +0800
Message-ID: <47F0C101.9090302@cn.fujitsu.com>
References: <47F0AA16.1070900@cn.fujitsu.com> <20080331.181551.118587102.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59870 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752102AbYCaKrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 06:47:09 -0400
In-Reply-To: <20080331.181551.118587102.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E said the follo=
wing on 2008-3-31 17:15:
> In article <47F0AA16.1070900@cn.fujitsu.com> (at Mon, 31 Mar 2008 17:=
08:38 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:
>=20
>> Check length of setsockopt's optval, which provided by user, before =
copy it
>> from user space.
>=20
> Please use "<" not "=3D=3D".
>=20

There are two reasons that why I only check whether
len of optval is equal to that one in user space.
1. We currently copy the entire structure from user
   to kernel.
2. In other cases, such as IPV6_LEAVE/JOIN_ANYCAST,
   we check whether the len is equal to struct's len.

So, Yoshifuji-san, can you tell me more about why we
should use "<"? :)

--WCN


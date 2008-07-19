From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] IPv6: Fail with appropriate error code when sending RH0
Date: Sat, 19 Jul 2008 09:28:40 +0800
Message-ID: <48814348.7000503@cn.fujitsu.com>
References: <48646C84.1000207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?GB2312?B?WU9TSElGVUpJIEhpZGVha2kgLyC8qszZ06LD9w==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52246 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751485AbYGSBaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 21:30:11 -0400
In-Reply-To: <48646C84.1000207@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei =D0=B4=B5=C0:
> When sending IPv6 packet with RH0(Type 0 Routing Header),
> return EINVAL instead of EPERM.
>=20
> Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
> ---
>  net/ipv6/ipv6_sockglue.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>=20

Yoshifuji-san, please take a look at this patch.


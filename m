From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next] ipv6: recursive check rt->dst.from when call
 rt6_check_expired
Date: Wed, 19 Sep 2012 16:22:22 +0800
Message-ID: <505980BE.5060300@cn.fujitsu.com>
References: <1347602097-18034-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:33365 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751970Ab2ISIWW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 04:22:22 -0400
In-Reply-To: <1347602097-18034-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8814=E6=97=A5 13:54, roy.qing.li@gmail.=
com =E5=86=99=E9=81=93:
> From: Li RongQing <roy.qing.li@gmail.com>
>=20
> If dst cache dst_a copies from dst_b, and dst_b copies from dst_c, ch=
eck
> if dst_a is expired or not, we should not end with dst_a->dst.from, d=
st_b,
> we should check dst_c.
>=20
> CC: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---

Looks good to me,thanks rongqing :)

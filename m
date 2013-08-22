From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH V3] ipv6: handle Redirect ICMP Message with no Redirected
 Header option
Date: Thu, 22 Aug 2013 09:28:11 +0800
Message-ID: <5215692B.5090206@cn.fujitsu.com>
References: <521468C4.5020700@cn.fujitsu.com> <20130821111700.GE20223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:10774 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752185Ab3HVB2x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 21:28:53 -0400
In-Reply-To: <20130821111700.GE20223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B408=E6=9C=8821=E6=97=A5 19:17, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Wed, Aug 21, 2013 at 03:14:12PM +0800, Duan Jiong wrote:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>
>> rfc 4861 says the Redirected Header option is optional, so
>> the kernel should not drop the Redirect Message that has no
>> Redirected Header option. In this patch, the function
>> ip6_redirect_no_header() is introduced to deal with that
>> condition.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>=20
> Sorry for being so picky about local socket delivery before. You were=
 right
> all along.
>=20
> I just tested and reviewed this patch and everything is fine:
>=20
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>=20
> Just out of curiosity, can you tell because of which devices you did
> this patch?
In fact, i did this patch just because i want to learn more about the
ipv6 implemention.

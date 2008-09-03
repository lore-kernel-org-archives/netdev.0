From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH RESEND] ipv6: return with appropriate error code when
 sending RH0 using setsockopt()
Date: Wed, 03 Sep 2008 17:41:31 +0800
Message-ID: <48BE5BCB.6090404@cn.fujitsu.com>
References: <48BE4DA2.20800@cn.fujitsu.com> <20080903.022303.84950778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54651 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbYICJnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 05:43:31 -0400
In-Reply-To: <20080903.022303.84950778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =E5=86=99=E9=81=93:
> From: Shan Wei <shanwei@cn.fujitsu.com>
> Date: Wed, 03 Sep 2008 16:41:06 +0800
>=20
>>  I'm sorry to resend the patch, for that no one replied it from Jun =
27.
>>
>>  The kernel had removed the RH0(Type 0 Routing Header), but we can s=
till
>>  send IPv6 packet with RH0 using sendmsg() or setsockopt().
>>
>>  Compare with sendmsg() that returns EINVAL, but setsockopt() return=
 EPERM.
>>  The patch fix it.
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>=20
> I've tried to defer IPV6 patches that have semantic issues to an
> expert such as Yoshifuji-san, but he has dropped off the face of the
> planet for a while.
>=20
> I'll take a look at this if I get a chance.
>=20
thanks for your so fast reply=E3=80=82
I'm patient to wait for your ack.


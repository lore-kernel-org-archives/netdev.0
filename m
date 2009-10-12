From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
 (v4)
Date: Mon, 12 Oct 2009 07:48:19 +0200
Message-ID: <4AD2C323.8020701@hartkopp.net>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <20091010123522.GA24193@localhost.localdomain> <4AD2B2BF.8040706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:58193 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbZJLFtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 01:49:36 -0400
In-Reply-To: <4AD2B2BF.8040706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Neil Horman a =E9crit :
>>
>> (..)
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> Create a new socket level option to report number of queue overflows
>>
>> (..)
>>
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
> Thanks Neil
>=20
> I found no obvious error in this v4, except two long lines.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks for this nice solution to both of you!

I'm very happy to be able to use this generalized socket option with ca=
n-raw
sockets now and that it has been possible to find an efficient and clea=
r patch
for that.

Best regards,
Oliver

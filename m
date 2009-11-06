From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sock_bindtodevice() RCU-ification
Date: Fri, 06 Nov 2009 08:08:59 +0100
Message-ID: <4AF3CB8B.2090206@gmail.com>
References: <4AF201FC.3040908@gmail.com>	<20091105.210830.108657873.davem@davemloft.net> <20091105.223921.83639611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43052 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbZKFHI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 02:08:58 -0500
In-Reply-To: <20091105.223921.83639611.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Thu, 05 Nov 2009 21:08:30 -0800 (PST)
>=20
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 04 Nov 2009 23:36:44 +0100
>>
>>> Avoid dev_hold()/dev_put() in sock_bindtodevice()
>>>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Applied to net-next-2.6, thanks.
>=20
> Eric I had to add the following patch to cure a build
> warning after this, just FYI:
>=20
> net: Fix build warning in sock_bindtodevice().
>=20
> net/core/sock.c: In function 'sock_setsockopt':
> net/core/sock.c:396: warning: 'index' may be used uninitialized in th=
is function
> net/core/sock.c:396: note: 'index' was declared here
>=20
> GCC can't see that all paths initialize index, so just
> set it to the default (0) and eliminate the specific
> code block that handles the null device name string.
>=20

Thanks David, which gcc version are you using ?


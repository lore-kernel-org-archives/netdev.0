From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v3] net: mac802154: comparision issue of type cast, finding
 by EXTRA_CFLAGS=-W
Date: Thu, 25 Apr 2013 16:43:14 +0800
Message-ID: <5178ECA2.6020402@asianux.com>
References: <5175DFBC.7040000@asianux.com> <5175F7F7.7000703@asianux.com> <51766F74.2090007@asianux.com> <20130425.041044.768895561908042668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:37483 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892Ab3DYIoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:44:03 -0400
In-Reply-To: <20130425.041044.768895561908042668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8825=E6=97=A5 16:10, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Tue, 23 Apr 2013 19:24:36 +0800
>=20
>> >=20
>> > Need change ~(u8)0 to 0xff, or in mac802154_wpan_xmit(), "u8 chan"
>> > will never =3D=3D MAC802154_CHAN_NONE.
>> >=20
>> > The related warning:
>> >   net/mac802154/wpan.c:325:2: warning: comparison is always false
>> >   due to limited range of data type [-Wtype-limits]
>> >=20
>> > The related unit test:
>> >   cc -Wall -O2 -o test test.c
>> >   ./test
>> >   will output 'different'
>> >=20
>> >   (after use '0xff' instead of '~(u8)0', it will output 'equal')
>  ...
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> This change belong in the 'net' tree, but your patch won't apply
> cleanly there as this part of the header file looks slightly
> different there.
>=20
> Please respin your patch against 'net' and resubmit, thank you.
>=20

Excuse me, my English is not quite well, I guess your meaning is: send
patch v4, and change the subject to "[PATCH v4] mac802154: comparision
issue of type cast, finding by EXTRA_CFLAGS=3D-W".

Is it correct ?

(the change is for net/mac802154/mac802154.h, and exist in v3.9-rc8)

Thanks.

--=20
Chen Gang

Asianux Corporation

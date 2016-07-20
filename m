From: Shanker Wang <shankerwangmiao@gmail.com>
Subject: Re: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18 (and probably later)
Date: Wed, 20 Jul 2016 15:28:22 +0800
Message-ID: <6AE3EF50-B524-4125-95D2-A4975961318C@gmail.com>
References: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEB52@ExMbx1.iabg.de> <AM4PR0501MB19408B7B4BBFDE17EB980F74DB370@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilan Tayari <ilant@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?utf-8?Q?Pommnitz_J=C3=B6rg?= <Pommnitz@iabg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34383 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcGTH23 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 03:28:29 -0400
Received: by mail-pa0-f46.google.com with SMTP id fi15so15647645pac.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 00:28:28 -0700 (PDT)
In-Reply-To: <AM4PR0501MB19408B7B4BBFDE17EB980F74DB370@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> =D4=DA 2016=C4=EA7=D4=C219=C8=D5=A3=AC23:03=A3=ACIlan Tayari <ilant@m=
ellanox.com> =D0=B4=B5=C0=A3=BA
>=20
>> On the receiving side (e.g. fd01:1b10:1000::1) I see the decrypted p=
ackets with
>> the 2.6.23 kernel:
>> but NOT with the newer kernel:
>=20
> Hi Joerg,
>=20
> First steps to debug this would be:
> cat /proc/net/xfrm_stat
> ip -s xfrm state
> ip -s xfrm policy
>=20
> First command will show some error accounting, which can point to the=
 culprit code.
> Second and third command will show existing objects, and some statist=
ics like when the last packet was used with them.
>=20
> Last thing - for your safety you should keep those session keys priva=
te.
>=20
> Ilan.

Hi Joerg,

I think maybe you can try tcpdump -w to write the captured packets into=
 a file
and use tools like Wireshark to analyze and see what is going wrong. =20=
=20

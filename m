From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 12:31:41 +0200
Message-ID: <4A64478D.9030008@gmail.com>
References: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com>	 <200907201228.47125.remi.denis-courmont@nokia.com>	 <1248082487.4549.102.camel@violet>	 <200907201247.23020.remi.denis-courmont@nokia.com> <1248085261.4549.103.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?=
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51999 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbZGTKbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 06:31:46 -0400
In-Reply-To: <1248085261.4549.103.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann a =C3=A9crit :
> Hi Remi,
>=20
>>>>>> From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>>>>> isn't there are proper explaining commit message missing here?
>>>> AFAIK, a one-liners stick to the Subject line.
>>>>
>>>> (I use explicit From: due to my broken Microsoft-provided MTA).
>>> the From: is not the problem here. However it would be nice to have=
 a
>>> description of the change. Especially details like this is for debu=
gging
>>> or this is a public API or etc.
>> It's just like most network protocols exposing their sockets list in=
=20
>> /proc/net. Debugging/monitoring indeed.
>=20
> I think that for new protocols, we should not do this anymore and jus=
t
> use debugfs. Since that is exactly its job.

netstat uses /proc/net

iproute2 uses netlink

Now you suggest adding debugfs support ?

What a mess...


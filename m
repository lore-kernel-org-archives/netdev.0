From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Tue, 10 Feb 2009 16:40:04 +0100
Message-ID: <49919FD4.3000008@dev.6wind.com>
References: <498ABDA2.5040603@dev.6wind.com>	<20090205.234520.149982266.davem@davemloft.net>	<498C403D.9040500@dev.6wind.com> <20090206.141026.85510254.davem@davemloft.net>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:48002 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753454AbZBJPkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 10:40:19 -0500
In-Reply-To: <20090206.141026.85510254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06.02.2009 23:10, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
> Date: Fri, 06 Feb 2009 14:50:53 +0100
>=20
>> If namespace is destroyed after this function, then cleanup_net()
>> will ensure that nobody is looking at it
>=20
> Maybe, but you better get some opinions from the people who wrote
> and maintain the network namespace code before I can consider
> your change seriously.
>=20
> None of them responded to your patch posting, probably because
> you failed to CC: any of them.
Sorry, I forget to cc them, now it's done.
The thread can be found here: http://marc.info/?l=3Dlinux-netdev&m=3D12=
3382930115535&w=3D2

So, I'm waiting for maintainers's opinions.

Thank you,
Nicolas

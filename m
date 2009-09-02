From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sk_free() should be allowed right after sk_alloc()
Date: Tue, 01 Sep 2009 17:50:01 -0700 (PDT)
Message-ID: <20090901.175001.219331524.davem@davemloft.net>
References: <20090831093019.GI5005@ff.dom.local>
	<20090831.050220.255723045.davem@davemloft.net>
	<4A9BBE12.4080206@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755347AbZIBAtq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 20:49:46 -0400
In-Reply-To: <4A9BBE12.4080206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 31 Aug 2009 14:12:02 +0200

> David Miller a =E9crit :
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Mon, 31 Aug 2009 09:30:19 +0000
>>=20
>>> On Mon, Aug 31, 2009 at 11:15:36AM +0200, Eric Dumazet wrote:
>>>> From: Jarek Poplawski <jarkao2@gmail.com>
>>>>
>>>> After commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
>>>> (net: No more expensive sock_hold()/sock_put() on each tx)
>>>> sk_free() frees socks conditionally and depends
>>>> on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some
>>> Very nice, but I hope David could fix btw. my "beeing" misspelling.
>>=20
>> I will :-)
>=20
> Thanks :)

Applied to net-2.6, thanks everyone.

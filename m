From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sk_free() should be allowed right after sk_alloc()
Date: Mon, 31 Aug 2009 14:12:02 +0200
Message-ID: <4A9BBE12.4080206@gmail.com>
References: <4A9B7956.40507@gmail.com>	<4A9B94B8.4050808@gmail.com>	<20090831093019.GI5005@ff.dom.local> <20090831.050220.255723045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35133 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbZHaMMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 08:12:03 -0400
In-Reply-To: <20090831.050220.255723045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 31 Aug 2009 09:30:19 +0000
>=20
>> On Mon, Aug 31, 2009 at 11:15:36AM +0200, Eric Dumazet wrote:
>>> From: Jarek Poplawski <jarkao2@gmail.com>
>>>
>>> After commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
>>> (net: No more expensive sock_hold()/sock_put() on each tx)
>>> sk_free() frees socks conditionally and depends
>>> on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some
>> Very nice, but I hope David could fix btw. my "beeing" misspelling.
>=20
> I will :-)

Thanks :)


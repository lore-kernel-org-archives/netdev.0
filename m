From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: You have to fix this
Date: Fri, 28 Sep 2012 17:29:22 +0530
Message-ID: <5065911A.3000509@chelsio.com>
References: <20120927.183406.962014014858457666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23947 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab2I1L71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 07:59:27 -0400
In-Reply-To: <20120927.183406.962014014858457666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 28-09-2012 04:04, David Miller wrote:
>=20
> You cannot put such monster sized local data objects on the stack:
>=20
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c: In function =91t4_memory_=
rw.constprop.6=92:
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:484:1: warning: the frame =
size of 2056 bytes is larger than 2048 bytes [-Wframe-larger-than=3D]
>=20
> That's because of this thing:
>=20
> 		__be32 data[MEMWIN0_APERTURE/sizeof(__be32)];
>=20
> I'm really surprised this didn't show up in any of your test builds.
> Or are you ignoring warnings that your changes add?
>=20

Thanks for pointing this out. We will send a patch for this soon.
I am not ignoring any warnings. I did build my tree different way as
shown below but did not get above warning message.
#> make
#> make allmodconfig
#> make allnoconfig

Please let me know how else would I get above warning message?

I missed doing make checkstack which doesn't display warning message bu=
t
lists the function names.

Thanks,
Vipul Pandya

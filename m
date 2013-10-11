From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netem: free skb's in tree on reset
Date: Fri, 11 Oct 2013 17:31:29 -0400 (EDT)
Message-ID: <20131011.173129.1844608099690115807.davem@davemloft.net>
References: <20131006151533.52988624@nehalam.linuxnetplumber.net>
	<20131006151649.38038c0e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756444Ab3JKVbb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 17:31:31 -0400
In-Reply-To: <20131006151649.38038c0e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 6 Oct 2013 15:16:49 -0700

> Netem can leak memory because packets get stored in red-black
> tree and it is not cleared on reset.
>=20
> Reported by: =F3=C5=D2=C7=C5=C5=D7 =F3=C5=D2=C7=C5=CA <adron@yapic.ne=
t>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.

From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 22:16:23 +0100
Message-ID: <478D22A7.6080506@cosmosbay.com>
References: <20080112064646.282104074@linux-foundation.org>	<20080112.205520.55747078.davem@davemloft.net>	<4789A29C.6080000@linux-foundation.org>	<20080112.214417.154179770.davem@davemloft.net>	<20080114125755.6157a3bf@deepthought>	<20080114164450.55f8c9b2@deepthought>	<20080114164621.2bc5011f@deepthought>	<20080114164727.210047f6@deepthought>	<20080114185843.0981f0ff@deepthought>	<20080114210716.4b09c84d@deepthought>	<478C4EB7.6060807@cosmosbay.com>	<478C4FBE.5040308@cosmosbay.com>	<20080115081905.3b8b6f05@deepthought>	<18316.58111.211387.271534@robur.slu.se>	<20080115182544.98c18d08.dada1@cosmosbay.com>	<20080115094753.32e35823@deepthought> <18317.5368.952926.46132@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44100 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbYAOVQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 16:16:36 -0500
In-Reply-To: <18317.5368.952926.46132@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Olsson a =E9crit :
>=20
> Stephen Hemminger writes:
>  > This is how I did it:
>=20
>  Yes looks like an elegant solution. Did you even test it?
>  Maybe we see some effects in just dumping a full table?
>=20
>  Anyway lookup should be tested in some way. We can a lot
>  of analyzing before getting to right entry, local_table
>  backtracking, main lookup w. ev. backtracking etc.  So
>  hopefully we get paid for this work.
>=20
>  Also it might be idea to do some analysis of the fib_aliases
>  list. Maybe the trick can be done again? ;)
>=20

Back in 2.6.9 times, sizeof(bi_alias) was 16 bytes on i386

Nowadays, 64/128 bytes are the norm :(

SLAB_HWCACHE_ALIGN is not our friend.


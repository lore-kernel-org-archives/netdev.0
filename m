From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 21:48:41 +0100
Message-ID: <p733avd25ee.fsf@bingen.suse.de>
References: <20071110131428.GA6447@gondor.apana.org.au>
	<20071110.223243.114494952.yoshfuji@linux-ipv6.org>
	<20071110143325.GA6888@gondor.apana.org.au>
	<20071110.234854.10674315.yoshfuji@linux-ipv6.org>
	<20071110145536.GA7024@gondor.apana.org.au>
	<4735C8E9.4030401@cosmosbay.com> <4735CB59.2050708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	=?shift_jis?B?WU9TSElGVUpJIEhpZGVha2kgLyCLZ5OhiXCWvg==?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:48599 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbXKJUsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2007 15:48:46 -0500
In-Reply-To: <4735CB59.2050708@cosmosbay.com> (Eric Dumazet's message of "Sat\, 10 Nov 2007 16\:16\:41 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:
>
> I meant a netstat bug of course, sorry :(
>
> It fails to parse /proc/net/netstat , because TcpExt line is bigger
> than 1024 chars.

guilty -- i wrote that code a long time ago.

>
> To correct it, we might enlarge buf1[] and buf2[] from 1024 to 2048 in
> statistics.c, process_fd() function.

Or just split TcpExt: into multiple lines, e.g. with a TcpExt2: 
No reason to have it all on a single line anyways.
I think that would be the better fix.

-Andi

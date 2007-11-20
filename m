From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: Async crypto support in IPsec
Date: Tue, 20 Nov 2007 09:43:04 +0100
Message-ID: <20071120084304.GA30366@Chamillionaire.breakpoint.cc>
References: <BFECAF9E178F144FAEF2BF4CE739C668039A0CD0@exmail1.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Jesper Bengtsson <jesper.bengtsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:50263 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753568AbXKTInG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 03:43:06 -0500
Content-Disposition: inline
In-Reply-To: <BFECAF9E178F144FAEF2BF4CE739C668039A0CD0@exmail1.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jesper Bengtsson | 2007-11-20 08:22:29 [+0100]:

>I've seen that async crypto support made it's way into the crypto API in
>2.6.22.
>From skimming the netdev-list I can see that some of you are working on
>async crypto support in IPsec as well. Do you have any idea when it will
>be available?
Async IPsec is in David Miller's .25 tree.

>The crisv32 crypto accelerator supports hashing and encryption in one
>single operation. Do you have any plans for supporting hashing and
>encryption in one operation?
The s390 supports crypto and hashing in one single operation as well.
Take a look on [1] for hasing and [2] crypto. Evgeniy made a HW driver
for the async API [3] which sould be in .25.

[1] linux 2.6.23 arch/s390/crypto/sha1_s390.c
[2] linux 2.6.23 arch/s390/crypto/aes_s390.c
[3] http://git.kernel.org/?p=linux/kernel/git/herbert/cryptodev-2.6.git;a=commit;h=c93e237e8c73f2b20c8c7b3fbcb2bd77ad06b4b6

>Thanks in advance,
>Jesper
Sebastian

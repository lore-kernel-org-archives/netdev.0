From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 12515] New: possible circular locking #0:
	(sk_lock-AF_PACKET){--..}, at: [<c1279838>]
	sock_setsockopt+0x12b/0x4a4
Date: Fri, 30 Jan 2009 13:56:17 +0000
Message-ID: <20090130135617.GA16106@ff.dom.local>
References: <497FB1C4.3000602@ribosome.natur.cuni.cz> <20090130124947.GA6886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin =?iso-8859-2?Q?MOKREJ=A9?=
	<mmokrejs@ribosome.natur.cuni.cz>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	vegard.nossum@gmail.com, a.p.zijlstra@chello.nl,
	davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:15724 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbZA3N41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 08:56:27 -0500
Received: by ug-out-1314.google.com with SMTP id 39so25949ugf.37
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 05:56:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090130124947.GA6886@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 11:49:47PM +1100, Herbert Xu wrote:
...
> Dave pointed out that a spin lock is illegal for this purpose
> as vm_insert_page can do a GFP_KERNEL allocation.  So I've added
> a mutex for this.
...
> I resisted the temptation to create a new spin lock because the
> mmap path isn't exactly common.

So, Dave is stronger than the temptation...

Jarek P.

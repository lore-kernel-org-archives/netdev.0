From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via /proc
Date: Sun, 07 Nov 2010 22:52:22 +0100
Message-ID: <87sjzcssx5.fsf@basil.nowhere.org>
References: <1289074307.3090.100.camel@Dan>
	<AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com>
	<20101106234840.GD2935@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	"chas\@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"kuznet\@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas\@netcore.fi" <pekkas@netcore.fi>,
	"jmorris\@namei.org" <jmorris@namei.org>,
	"yoshfuji\@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber\@trash.net" <kaber@trash.net>,
	"remi.denis-courmont\@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"security\@kernel.org" <security@kernel.org>
To: Ted Ts'o <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55393 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab0KGVw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 16:52:28 -0500
In-Reply-To: <20101106234840.GD2935@thunk.org> (Ted Ts'o's message of "Sat, 6
	Nov 2010 19:48:40 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ted Ts'o <tytso@mit.edu> writes:

> Are there any userspace programs that might be reasonably expected to
> _use_ this information?  If there is, we could just pick a random
> number at boot time, and then XOR the heap adddress with that random
> number.

If any of the addresses can be guessed ever (and that is likely if it's
allocated at boot) determining the random value will be trivial
for everyone.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

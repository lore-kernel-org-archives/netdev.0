From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via /proc
Date: Sun, 07 Nov 2010 17:48:45 -0500
Message-ID: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
References: <87sjzcssx5.fsf@basil.nowhere.org>
Reply-To: chas3@users.sourceforge.net
Cc: "Ted Ts'o" <tytso@mit.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"kuznet\@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas\@netcore.fi" <pekkas@netcore.fi>,
	"jmorris\@namei.org" <jmorris@namei.org>,
	"yoshfuji\@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber\@trash.net" <kaber@trash.net>,
	"remi.denis-courmont\@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"security\@kernel.org" <security@kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:50529 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab0KGXGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 18:06:32 -0500
In-reply-to: <87sjzcssx5.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <87sjzcssx5.fsf@basil.nowhere.org>,Andi Kleen writes:
>Ted Ts'o <tytso@mit.edu> writes:
>
>> Are there any userspace programs that might be reasonably expected to
>> _use_ this information?  If there is, we could just pick a random
>> number at boot time, and then XOR the heap adddress with that random
>> number.
>
>If any of the addresses can be guessed ever (and that is likely if it's
>allocated at boot) determining the random value will be trivial
>for everyone.

i suppose one could use idr to map the pointers to unique values.  the
infiniband code uses this technique>

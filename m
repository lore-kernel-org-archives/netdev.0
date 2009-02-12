From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Thu, 12 Feb 2009 11:58:04 -0800
Message-ID: <m1wsbvctrn.fsf@fess.ebiederm.org>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>
	<20090212001223.GA5757@movementarian.org>
	<alpine.DEB.2.00.0902121006440.18739@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wli@movementarian.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0902121006440.18739@blackhole.kfki.hu> (Jozsef Kadlecsik's message of "Thu\, 12 Feb 2009 10\:11\:43 +0100 \(CET\)")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jozsef Kadlecsik <kadlec@blackhole.kfki.hu> writes:

> On Wed, 11 Feb 2009, wli@movementarian.org wrote:
>
>> On Wed, Feb 11, 2009 at 11:19:20AM +0100, Jozsef Kadlecsik wrote:
>> >  /* The golden ration: an arbitrary value */
>> > -#define JHASH_GOLDEN_RATIO	0x9e3779b9
>> > +#define JHASH_GOLDEN_RATIO	0xdeadbeef
>> 

0xdeadbeef is a really bad choice of an arbitrary value.  It is
already used in multiple places.  Only a few of which are currently
listed in linux/poison.h and if I happened to see that number in a
debug trace having to sort through all of the possible sources looks
like a major pain.

I don't really care what we call it but somehow 0xdeadbeef strikes me
as wrong and something that will make debugging harder.

Eric

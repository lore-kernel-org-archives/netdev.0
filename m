From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 09 Aug 2007 11:10:16 +0200
Message-ID: <E1IJ424-0000d7-HK@be1.lrz>
References: <8Q2Pg-8uV-23@gated-at.bofh.it> <8Q7Fa-7rJ-1@gated-at.bofh.it> <8Q8rD-hh-7@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jerry Jiang <wjiang@resilience.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>, akpm@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com,
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:51672 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765290AbXHIJKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 05:10:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jerry Jiang <wjiang@resilience.com> wrote:
> On Wed, 8 Aug 2007 21:18:25 -0700 (PDT)
>> On Wed, 8 Aug 2007, Chris Snook wrote:

>> > Some architectures currently do not declare the contents of an ato=
mic_t to
>> > be
>> > volatile.  This causes confusion since atomic_read() might not act=
ually
>> > read anything if an optimizing compiler re-uses a value stored in =
a
>> > register, which can break code that loops until something external=
 changes
>> > the value of an atomic_t.
>>=20
>> I'd be *much* happier with "atomic_read()" doing the "volatile" inst=
ead.
>>=20
>> The fact is, volatile on data structures is a bug. It's a wart in th=
e C
>> language. It shouldn't be used.
>=20
> Why? It's a wart! Is it due to unclear C standard on volatile related=
 point?
>=20
> Why the *volatile-accesses-in-code* is acceptable, does C standard ma=
ke it
> clear?

http://lwn.net/Articles/233482/
--=20
=46un things to slip into your budget
Heisenberg Compensator upgrade kit

=46ri=DF, Spammer: uWfuXeviZ@x.7eggert.dyndns.org

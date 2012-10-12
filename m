From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 12:00:03 +0100
Message-ID: <yw1xhaq0nefg.fsf@unicorn.mansr.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	<AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
	<yw1xtxu1nfsn.fsf@unicorn.mansr.com>
	<201210120811.43290.arnd@arndb.de>
	<20121012090321.GA21164@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	=?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([78.86.181.103]:48562 "EHLO
	unicorn.mansr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914Ab2JLLAF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 07:00:05 -0400
In-Reply-To: <20121012090321.GA21164@n2100.arm.linux.org.uk> (Russell King's
	message of "Fri, 12 Oct 2012 10:03:21 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux <linux@arm.linux.org.uk> writes:

> On Fri, Oct 12, 2012 at 08:11:42AM +0000, Arnd Bergmann wrote:
>> On Thursday 11 October 2012, M=E5ns Rullg=E5rd wrote:
>> > > But, the IP header is expected to be aligned.
>> >=20
>> > Everything tells the compiler the struct is perfectly aligned.  Wh=
en the
>> > buggy driver passes a misaligned pointer, bad things happen.
>>=20
>> Would it be appropriate to add a WARN_ON_ONCE() in the alignment fau=
lt path
>> then?

I think that's an excellent idea.

>> If all alignment faults in the kernel are caused by broken drivers,
>> that would at least give us some hope of finding those drivers while
>> at the same time not causing much overhead in the case where we need
>> to do the fixup in the meantime.
>
> No.  It is my understanding that various IP option processing can als=
o
> cause the alignment fault handler to be invoked, even when the packet=
 is
> properly aligned, and then there's jffs2/mtd which also relies upon
> alignment faults being fixed up.

As far as I'm concerned, this is all hearsay, and I've only ever heard
it from you.  Why can't you let those who care fix these bugs instead?

--=20
M=E5ns Rullg=E5rd
mans@mansr.com

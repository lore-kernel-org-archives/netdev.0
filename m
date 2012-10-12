From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 12:18:08 +0100
Message-ID: <yw1x8vbcndlb.fsf@unicorn.mansr.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	<AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
	<yw1xtxu1nfsn.fsf@unicorn.mansr.com>
	<201210120811.43290.arnd@arndb.de>
	<20121012090321.GA21164@n2100.arm.linux.org.uk>
	<yw1xhaq0nefg.fsf@unicorn.mansr.com>
	<20121012110750.GE21164@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([78.86.181.103]:51210 "EHLO
	unicorn.mansr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab2JLLSK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 07:18:10 -0400
In-Reply-To: <20121012110750.GE21164@n2100.arm.linux.org.uk> (Russell King's
	message of "Fri, 12 Oct 2012 12:07:50 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux <linux@arm.linux.org.uk> writes:

> On Fri, Oct 12, 2012 at 12:00:03PM +0100, M=E5ns Rullg=E5rd wrote:
>> Russell King - ARM Linux <linux@arm.linux.org.uk> writes:
>>=20
>> > On Fri, Oct 12, 2012 at 08:11:42AM +0000, Arnd Bergmann wrote:
>> >> On Thursday 11 October 2012, M=E5ns Rullg=E5rd wrote:
>> >> > > But, the IP header is expected to be aligned.
>> >> >=20
>> >> > Everything tells the compiler the struct is perfectly aligned. =
 When the
>> >> > buggy driver passes a misaligned pointer, bad things happen.
>> >>=20
>> >> Would it be appropriate to add a WARN_ON_ONCE() in the alignment
>> >> fault path then?
>>=20
>> I think that's an excellent idea.
>
> Well, I get the last word here and it's no.

Sadly, yes.

>> >> If all alignment faults in the kernel are caused by broken driver=
s,
>> >> that would at least give us some hope of finding those drivers wh=
ile
>> >> at the same time not causing much overhead in the case where we n=
eed
>> >> to do the fixup in the meantime.
>> >
>> > No.  It is my understanding that various IP option processing can =
also
>> > cause the alignment fault handler to be invoked, even when the pac=
ket is
>> > properly aligned, and then there's jffs2/mtd which also relies upo=
n
>> > alignment faults being fixed up.
>>=20
>> As far as I'm concerned, this is all hearsay, and I've only ever hea=
rd
>> it from you.  Why can't you let those who care fix these bugs instea=
d?
>
> You know, I'm giving you the benefit of my _knowledge_ which has been
> built over the course of the last 20 years.

How proud you sound.  Now could you say something of substance instead?

> I've been in these discussions with networking people before.  I ende=
d
> up having to develop the alignment fault handler because of those
> discussions.  And oh look, Eric confirmed that the networking code
> isn't going to get "fixed" as you were demanding, which is exactly
> what I said.

=46unny, I saw him say the exact opposite:

  So if you find an offender, please report a bug, because I can
  guarantee you we will _fix_ it.

> I've been in discussions with MTD people over these issues before, I'=
ve
> discussed this with David Woodhouse when it came up in JFFS2.  I *KNO=
W*
> these things.

In the same way you "know" the networking people won't fix their code,
despite them _clearly_ stating the opposite?

> You can call it hearsay if you wish, but it seems to be more accurate
> than your wild outlandish and pathetic statements.

So you're resorting to name-calling.  Not taking that bait.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com

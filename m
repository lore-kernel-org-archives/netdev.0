From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ip: fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 12:24:06 -0700 (PDT)
Message-ID: <20100921.122406.193718558.davem@davemloft.net>
References: <20100921162657.GA22183@khazad-dum.debian.net>
	<1285086679.2617.672.camel@edumazet-laptop>
	<20100921180940.GA8754@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, nbowler@elliptictech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jarkao2@gmail.com, kaber@trash.net
To: hmh@hmh.eng.br
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100921180940.GA8754@khazad-dum.debian.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Date: Tue, 21 Sep 2010 15:09:40 -0300

> On Tue, 21 Sep 2010, Eric Dumazet wrote:
>> Le mardi 21 septembre 2010 =E0 13:26 -0300, Henrique de Moraes Holsc=
huh a
>> =E9crit :
>> > Should this be a candidate for -stable?
>> >=20
>>=20
>> Yes, of course, but David wants to handle stable submissions himself=
=2E
>>=20
>> I am not sure we want to bug stable team with dozens of mails while
>> polishing patches ?
>=20
> We don't.  But one often marks commits that should go to -stable usin=
g a Cc:
> pseudo-header, and also includes relevant information (e.g. to which =
stable
> kernels it should be applied to) to the commit message.
>=20
> Since there wasn't one, and I didn't readly find any post in this thr=
ead
> that mentioned it should also go to stable, AND it looked at first gl=
ance
> like something that should go to stable, I asked about it.

Sorry, that is not how we typically handle things in the networking.

I queue up all appropriate -stable patches automatically.

I do this mainly because:

1) It isn't the submitter who gets to decide all by himself that
   something is -stable material, that's partly my job too.

   So if the submitter puts the CC: stable thing in the commit
   message, that takes me out of the decision making process.

2) I do not want -stable submissions to go in just because a patch
   made it into Linus's tree.

   I want fixes to sit and cook in Linus's tree for a while before
   they go to -stable unless it's an _incredibly_ obvious fix.
   This allows any bugs in the fix to be shaken out first.

   Again, the CC: stable tag subverts that.

I really think the "CC: stable" tag is only appropriate for a very
limited scope of bug fixes.  The incredibly obvious ones that need
almost no testing and time exposure in Linus's tree.

All of the rest should be carefully queued up for -stable and
submitted there after a week or two of the patch sitting in Linus's
tree.

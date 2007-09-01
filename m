From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sat, 1 Sep 2007 21:30:52 +0100
Message-ID: <20070901213052.530483c3@the-village.bc.nu>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
	<f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "Constantine A. Murenin" <mureninc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:53122 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755039AbXIAUWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 16:22:22 -0400
In-Reply-To: <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It is illegal to modify a license unless you are the owner/author,
> because it is a legal document.  If there are multiple owners/authors,

Oh dear - Theo, go talk to a lawyer, or do a course on licencing.

The owner generally starts with the rights to control who performs acts
covered by copyright law. They pass some of those rights on to others by
contract, licence or statutory means. It is quite normal for the owner to
pass on the right to relicence or modify the licencing of a work. In many
cases the owner actually hands on all such rights to a third party
(eg an evil music company).

[Owner and author often differ as many legal systems start from the basis
that an employee produces a work for the employer rather than it being
transferred solely by contract]

The ath5k C file in question (not the headers) seems to give recipients
permission to further convey the work under a choice of two licences. It
doesn't say they must redistribute under both. So I appear to have a
right to convey the work under the GPL to a third party, who from me
receives no right to use it except under the GPL. 

The Ath5K C code is very clear about the intention of the licencing:

 * Alternatively, this software may be distributed under the terms of the
 * GNU General Public License ("GPL") version 2 as published by the Free
 * Software Foundation.

The choice appears to be delegated to the recipient very clearly and
very specifically by the licencing on the file. It does not say that I
must convey the work under both licences. It quite specifically says I may
convey the work under whichever of the two I prefer (and probably both if
I wish). Clearly if that had not been the intent it would not have
included the clause giving the choice.

This is quite different to the case Theo tries to discuss.

> In http://lkml.org/lkml/2007/8/29/183, Alan Cox managed to summarize
> what Jiri Slaby and Luis Rodriguez were trying to do by proposing a
> modification of a Dual Licenced file without the consent of all the
> authors.  Alan asks "So whats the problem ?".  Well, Alan, I must
> caution you -- your post is advising people to break the law.

Re-read my email and then apologize. I do question the .h files where
they are BSD licence and no changes were made to the work. I also point
out that the dual licence on that code appears to give permission to
distribute under one of those licences by choice.

> - If you receive dual licensed code, you may not delete the license
>   you don't like and then distribute it.  It has to stay, because you
>   may not edit someone's else's license -- which is a three-part legal
>   document (For instance: Copyright notice, BSD, followed by GPL).

If you got BSD licenced code that doesn't give you a choice of licence
then of course the original work remains BSD and you can't go around
removing that information, the copyright holder's name and other things
protected variously by different legal systems. I would submit the ath5k
header files fit this (if they are even copyrightable works at all)

> - If you wish for everyone to remain friends, you should give code back.

That's about the first thing I would agree on - its somewhat rude and
not something I personally woul usually choose todo.  However to many
there are problems as the BSD licence doesn't mean giving it back to the
community it means giving a copy to everyone who wants rip it off for
private proprietary use.

>      "Thanks for what you wrote, but this is a one-way street, you give
>      us code, and we take it, we give you you nothing back.  screw off."

The BSD licence allows this. If you in the BSD world don't want that to
happen you need to look hard at your licencing. Linux takes very little
from the BSD world this way, the big one way takers are all proprietary
software companies. Perhaps Theo should write to that nice Bill guy
instead.

> GPL fans said the great problem we would face is that companies would
> take our BSD code, modify it, and not give back.  Nope -- the great
> problem we face is that people would wrap the GPL around our code, and

You just don't realise who takes your code and what they do with it. The
proprietary people don't tell you, but the free ones you can see.

> If the Linux developers wrap GPL's around things we worked very hard
> on, it will definately not be viewed as community development.

So you'd prefer that the Linux developers worked on it and then Microsoft
took the results of all our work and didn't give anything back. At least
if the Linux work is GPL licenced its protected from further abuse. See
the viewpoint the free software people come from - you may not agree with
it but it has a logic.

If OpenBSD wants a world where code must be returned, but you can mix it
with free code in a product in some fashion and do binary only releases
then OpenBSD needs to fix its licencing. Not to GPL which is clearly not
the BSD intention but to something which does what BSD wants rather than
an academic research licence developed thirty odd years ago for the
purpose of showing that US research funds were properly spent. Perhaps
its time for BSD2 licencing ?

Alan

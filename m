From: "Constantine A. Murenin" <mureninc@gmail.com>
Subject: Re: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 01:09:18 -0400
Message-ID: <f34ca13c0709012209x64c282b9o1fd0cb7d08690247@mail.gmail.com>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
	 <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
	 <46D99FB7.6030505@garzik.org>
	 <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
	 <20070901205457.GK9260@stusta.de> <20070901215225.GM9260@stusta.de>
	 <3A831845-B630-42AD-B52F-DC9EA2060BAE@dixongroup.net>
	 <20070902015537.GH16016@stusta.de>
	 <5619.1188704843@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@kernel.org>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>, jirislaby@gmail.com,
	"Nick Kossifidis" <mickflemm@gmail.com>
To: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758046AbXIBFJe@vger.kernel.org>
In-Reply-To: <5619.1188704843@turing-police.cc.vt.edu>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/07, Valdis.Kletnieks@vt.edu <Valdis.Kletnieks@vt.edu> wrote:
> On Sun, 02 Sep 2007 03:55:37 +0200, Adrian Bunk said:
>
> > Jiri's patch would have wrongly not only removed the BSD statement from
> > dual licenced files but also from not dual licenced files.
> >
> > This was a mistake in this patch (that was never merged into the tree)
> > neither Jiri nor Alan noticed.
>
> You know, we *could* have solved this a *hell* of a lot easier if people quit
> flaming about it, and we did something *productive* instead.
>
> Like submit a corrected patch. :)

Dear Valdis,

The idea here is that no patching was needed in the first place --
most of the files are/were BSD-licensed, because they were forked from
OpenBSD.

It is beneficial for the atmosphere of both projects to keep the
licence compatible. If Linux tries to GPL future modifications to
Reyk's code, then OpenBSD would not be able to take back the changes.
But this would not be the case if all modifications to Reyk's code are
continued to be BSD-licensed. This is what this whole issue is about.

My understanding, is that Nick Kossifidis never had a problem with
licensing his changes with a BSD-license, although Jiri Slaby always
used GPLv2.

With the last patch posted by Luis [0], Jiri actually recalled his
original patch and relicensed all of his GPLv2 work under BSD (!);
however, at the very same time, Nick changed his mind, and decided to
relicense his BSD code under GPLv2 (!). (Surprise! Yes, it appears
that both Nick and Jiri decided to switch their licensing positions,
and mutually relicense their work under each other's respective
licence. :) Is everyone ready going to go back and forth now? Does
this whole story still makes any sense to you? :)

I hope that both Nick Kossifidis and Jiri Slaby can agree on licensing
their HAL code with a BSD licence, so that the code remains
licence-compatible with OpenBSD. If there are any unresolved licensing
questions, I personally would be more than happy to answer any such
questions as much as I can, and yes -- I am not a lawyer. :)

Nick, Jiri -- since much of the work on OpenHAL is based on Reyk's
HAL, could you please be so kind as to both agree to licence you
changes in OpenHAL with the same licence as Reyk does in OpenBSD's
ath(4) HAL? This step will be very welcome in the OpenBSD community at
large.

Best regards,
Constantine.

[0] http://marc.info/?l=linux-wireless&m=118857712529898&w=2

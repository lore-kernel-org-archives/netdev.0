From: "Sverre Rabbelier" <alturin@gmail.com>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 14:15:22 +0200
Message-ID: <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com>
References: <47FEADCB.7070104@rtr.ca> <20080413205406.GA9190@2ka.mipt.ru>
	 <48028830.6020703@earthlink.net>
	 <alpine.DEB.1.10.0804131546370.9318@asgard>
	 <20080414043939.GA6862@1wt.eu>
	 <20080414053943.GU9785@ZenIV.linux.org.uk>
	 <20080413232441.e216a02c.akpm@linux-foundation.org>
	 <20080414072328.GW9785@ZenIV.linux.org.uk>
	 <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
	 <4804765B.2070300@davidnewall.com>
Reply-To: sverre@rabbelier.nl
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "James Morris" <jmorris@namei.org>,
	"Al Viro" <viro@zeniv.linux.org.uk>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Willy Tarreau" <w@1wt.eu>, david@lang.hm,
	"Stephen Clark" <sclark46@earthlink.net>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Tilman Schmidt" <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	"Mark Lord" <lkml@rtr.ca>, "David Miller" <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	netdev@vger.kernel.org, "David Newall" <davidn@davidnewall.com>
To: git@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <git-owner@vger.kernel.org>
In-Reply-To: <4804765B.2070300@davidnewall.com>
Content-Disposition: inline
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not subscribed to the kernel mailing list, so please include me in
the cc if you don't reply to the git list (which I am subscribed to).

Git is participating in Google Summer of Code this year and I've
proposed to write a 'git statistics' command. This command would allow
the user to gather data about a repository, ranging from "how active
is dev x" to "what did x work on in the last 3 weeks". It's main
feature however, would be an algorithm that ranks commits as being
either 'buggy', 'bugfix' or 'enhancement'. (There are several clues
that can aid in determining this, a commit msg along the lines of
"fixes ..." being the most obvious.)
In the light of this recent discussion, especially the part on
"keeping count of the number of errors introduced by
author and reviewer?", I thought it might for the kernel mailing list
to be aware of this. Also mentioned in this thread was that reviewers
don't get enough credits. As long as patches are signed with, say,
'reviewed-by:', 'acked-by:' or 'signed-off-by:' the command I suggest
to implement would be able to give more accurate statistics on who
"works on the kernel". This way reviewers get the credit they deserve.
The knife cuts on both sides of course, if someone reviews a patch
that is later determined to introduce a bug, they can be recorded to
have acked a buggy commit. This is especially interesting in
determining who are the good reviewers, but also in determining who
are the good contributors. A distinction could be made between parts
of the source, say, a maintainer might excel in patches related to
driver foo, but when they submit a patch for driver bar it usually
contains bugs . Armed with these statistics reviewers might decide to
be more careful before acking a patch from that maintainer if it's on
driver bar, but when that same maintainer sends in a patch from driver
bar it is probably ok and needs less attention.
My application, and a more extended description, can be found here:
http://alturin.googlepages.com/gsoc2008

I'm interested to know if the community is indeed as interested in my
proposal as I hope and if I oversaw any obvious features that would
make it an even better command.

Cheers,

Sverre Rabbelier

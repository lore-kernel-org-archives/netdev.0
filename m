From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 23:17:14 +0200
Message-ID: <9a8748490804161417n4ad6c1den54ccd302831a66c6@mail.gmail.com>
References: <47FEADCB.7070104@rtr.ca> <48028830.6020703@earthlink.net>
	 <alpine.DEB.1.10.0804131546370.9318@asgard>
	 <20080414043939.GA6862@1wt.eu>
	 <20080414053943.GU9785@ZenIV.linux.org.uk>
	 <20080413232441.e216a02c.akpm@linux-foundation.org>
	 <20080414072328.GW9785@ZenIV.linux.org.uk>
	 <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
	 <4804765B.2070300@davidnewall.com>
	 <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: git@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	"James Morris" <jmorris@namei.org>,
	"Al Viro" <viro@zeniv.linux.org.uk>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Willy Tarreau" <w@1wt.eu>, david@lang.hm,
	"Stephen Clark" <sclark46@earthlink.net>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Tilman Schmidt" <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	"Mark Lord" <lkml@rtr.ca>, "David Miller" <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, netdev@vger.kernel.org,
	"David Newall" <davidn@davidnewall.com>
To: sverre@rabbelier.nl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764233AbYDPVRu@vger.kernel.org>
In-Reply-To: <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/04/2008, Sverre Rabbelier <alturin@gmail.com> wrote:
...
>  Git is participating in Google Summer of Code this year and I've
>  proposed to write a 'git statistics' command. This command would allow
>  the user to gather data about a repository, ranging from "how active
>  is dev x" to "what did x work on in the last 3 weeks". It's main
>  feature however, would be an algorithm that ranks commits as being
>  either 'buggy', 'bugfix' or 'enhancement'.

Interresting. Just be careful results are produced for the big picture
and not used to point fingers at individuals.

>(There are several clues
>  that can aid in determining this, a commit msg along the lines of
>  "fixes ..." being the most obvious.)

One thing I thought of is that the more "Acked-by", "Reviewed-by" and
"Signed-off-by" lines a patch has, the better reviewed we can probably
assume it to be and thus the probability of it having introduced a bug
probably drops slightly compared to other less-reviewed patches... or
maybe not, but at least it's something to think about :-)


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

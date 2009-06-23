From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for
 rc-series and merge window
Date: Tue, 23 Jun 2009 12:11:52 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906231210040.3240@localhost.localdomain>
References: <20090622222217.GH23972@bombadil.infradead.org> <m3fxdqj2bz.fsf@lwn.net> <m3bpoen5pp.fsf@intrepid.localdomain> <20090623130602.6cd6b713@chukar>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Pavel Machek <pavel@ucw.cz>, Greg KH <greg@kroah.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: Jake Edge <jake@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54792 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752326AbZFWTMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 15:12:06 -0400
In-Reply-To: <20090623130602.6cd6b713@chukar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 23 Jun 2009, Jake Edge wrote:

> On Tue, 23 Jun 2009 20:52:02 +0200 Krzysztof Halasa wrote:
> 
> > Perhaps it's just me :-) but I think we're trying to codify the rules
> > way too much. The general rules (merge window = new features etc) are
> > obviously ok but why do we need strict details like intrusive vs
> > non-intrusive etc? People should just use a common sense and good
> > judgement and, if in doubt in some particular case, ask. We are unable
> > to describe all situations in a single text file.
> 
> Me2 :)

Well, I do agree that documenting the rules and making them inflexible 
shouldn't be the primary goal.

But the fact is, "common sense" hasn't worked very well. I consistently 
get pull requests from maintainers that have well-meaning "fix bugs" in 
them, and that cause a lot of totally pointless churn.

In fact, this whole discussion has shown one thing: people still think 
that "bug fix" somehow automatically means that it's appropriate after the 
merge window. That's simply not so. 

			Linus

From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 06:39:43 +0100
Message-ID: <20080414053943.GU9785@ZenIV.linux.org.uk>
References: <47FEADCB.7070104@rtr.ca> <20080413121831.d89dd424.akpm@linux-foundation.org> <20080413202118.GA29658@2ka.mipt.ru> <200804132233.50491.rjw@sisk.pl> <20080413205406.GA9190@2ka.mipt.ru> <48028830.6020703@earthlink.net> <alpine.DEB.1.10.0804131546370.9318@asgard> <20080414043939.GA6862@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david@lang.hm, Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57557 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbYDNFkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:40:42 -0400
Content-Disposition: inline
In-Reply-To: <20080414043939.GA6862@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2008 at 06:39:39AM +0200, Willy Tarreau wrote:

[snip]

> I'm sure many people would find this useless (or in fact reject the
> idea because it would show that most code will be rated 1 or 2),
> but I really think it can help subsystem maintainers make the relation
> between a reported bug and a possible submitter.

I have a related proposal: let us require all patches to be stamped
with Discordian *and* Eternal September dates.  In triplicate.  While
we are at it, why don't we introduce new mandatory headers like, say
it,

X-checkpatch: {Yes,No}
X-checkpatch-why-not: <string>
X-pointless: <number from 1 to 69, going from "1: does something useful" all
the way to "68: aligns right ends of lines in comments">
X-arbitrary-rules-added-to-CodingStyle: <number> (should be present if
and only if X-pointless: 69 is present).

Come to think of that, we clearly need a new file in Documentation/*,
documenting such headers.  Why don't we organize a subcommittee^Wnew maillist
devoted to that?  That would provide another entry route for contributors,
lowering the overall entry barriers even further...


Seriously, looks like Andi is right - we've got ourselves a developing
beaurocracy.  As in "more and more ways of generating activity without
doing anything even remotely useful".  Complete with tendency to operate in
the ways that make sense only to beaurocracy in question and an ever-growing
set of bylaws...

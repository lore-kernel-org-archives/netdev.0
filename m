From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Re: A reliable kernel panic (3.6.2) and system crash when
 visiting a particular website
Date: Sat, 20 Oct 2012 22:32:28 +0200
Message-ID: <20121020203227.GC555@elf.ucw.cz>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bp@alien8.de, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:41164 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755396Ab2JTUcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 16:32:32 -0400
Content-Disposition: inline
In-Reply-To: <966148591.30347.1350754909449.JavaMail.mail@webmail08>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat 2012-10-20 17:41:49, Artem S. Tashkinov wrote:
> On Oct 20, 2012, Borislav Petkov wrote: 
> 
> > Yeah, your kernel is tainted with a proprietary module (vbox*, etc). Can
> > you reproduce your corruptions (this is what it looks like) without that
> > module?
> 
> Yes, I can reproduce this panic with zero proprietary/non-free modules loaded.
> 
> The problem is the kernel doesn't even print a kernel panic - the
> system just freezes completely - cursor in a text console stops
> blinking.

bugtraq? :-).

If remote website can crash your Linux, that's quite significant news.

(Cc-ed netdev@ and security@ ... this may be important).
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

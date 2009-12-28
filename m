From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 21:55:11 +0100
Message-ID: <20091228205511.GD1637@ucw.cz>
References: <20091227190802.GH11737@elf.ucw.cz> <20091228060759.GB13266@heat> <20091228101006.GA19984@elf.ucw.cz> <8817.1262011044@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Am?rico Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:55408 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbZL1UzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 15:55:23 -0500
Content-Disposition: inline
In-Reply-To: <8817.1262011044@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 2009-12-28 09:37:24, Valdis.Kletnieks@vt.edu wrote:
> On Mon, 28 Dec 2009 11:10:06 +0100, Pavel Machek said:
> 
> > a) make disablenetwork reset to "enablenetwork" during setuid exec
> 
> That won't work either.  If you only make it 'setuid==0' binaries, you still
> break 'setuid-FOO' binaries that require the net. If you just check the setuid
> bit, it allows a trivial escape by creating a setuid-yourself binary and using
> that to exec something else (now with network access, because we apparently
> don't have a way to remember the previous setting).


it is really only required for binaries setuid to someone else, but
that would be too ugly. (Plus, as someone said, ping is great for
leaking data out.)

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

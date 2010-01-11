From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 11 Jan 2010 12:53:32 +0100
Message-ID: <20100111115332.GA1697@atrey.karlin.mff.cuni.cz>
References: <f73f7ab81001101418x3b3f8652j256f6311ad6244c5@mail.gmail.com> <20100110230839.GB3825@heat> <3e8340491001101541tc776ad9r887be13393bcb7fd@mail.gmail.com> <4B4A83E0.9000207@schaufler-ca.com> <3e8340491001101815p887b96dr22b9b3f3108a7541@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Michael Stone <michael@laptop.org>,
	Kyle Moffett <kyle@moffetthome.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
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
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Al Vir
To: Bryan Donlan <bdonlan@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3e8340491001101815p887b96dr22b9b3f3108a7541@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi!

> * If network access is restored over suid, then we can leak data over
> ping or any number of other routes, so that's right out.

ACK.

> * If network access is denied over suid, there are concerns of denial
> of service in certain configurations.

So that should be right out, too.

> * If suid is denied entirely, we have no denial of service or
> information leak concerns via the suid mechanism (since the mechanism
> is completely unusable). And if we really do need to execute something
> at an elevated privilege, we can ask a helper daemon to do it on our
> behalf.

Yes please. This is the obvious solution.
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: disablenetwork (v5) patches
Date: Sun, 17 Jan 2010 01:01:41 -0500
Message-ID: <f73f7ab81001162201v1956351boa9241ce440e62a09@mail.gmail.com>
References: <20100114173639.GA15587@us.ibm.com> <20100115081028.GA14004@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100115081028.GA14004@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2010 at 03:10, Michael Stone <michael@laptop.org> wrote:
> As promised, here are patches implementing and documenting a CAP_SETPCAP-gated
> "enable" bit along with a couple of other tweaks discussed earlier in the
> thread. For ease of development and review, the following four patches
> extend the disablenetwork (v4) patch series rather than replacing it.

To be honest, I'm still not convinced that this is the right way to
approach your problem.  I think you would be much better off with
something analogous to the stripped-down SELinux policy I sent in an
earlier email (150 lines, give or take).  By using the appropriate
SELinux hooks you can obtain the *exact* same enforcement, but without
adding any code to the kernel.

I have some time this week to split out my SELinux policy build
machinery; I will pull out a standalone set of files to build the
policy and do some extra testing on one of my bog-standard Debian
boxes and then send it all out again.

Cheers,
Kyle Moffett

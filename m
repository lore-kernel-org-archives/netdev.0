From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 18:08:39 -0500
Message-ID: <20100110230839.GB3825@heat>
References: <f73f7ab81001101418x3b3f8652j256f6311ad6244c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
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
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f73f7ab81001101418x3b3f8652j256f6311ad6244c5@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paraphrasing Kyle:

> Suppose there exist PAM modules which lazily fork background processes. Now
> assume that one of those PAM modules is hooked from /etc/pam.d/su, that the
> module fails closed when the network is unavailable, and that Mallory wins
> the race to start the daemon. Boom.

I'm not disagreeing that there are configurations of programs, written for
kernels without disablenetwork, which cease to be correct on kernels that
provide it. However, all this says to me is that people who need to use those
configurations probably shouldn't use disablenetwork. (Or that we haven't found
exactly the right semantics for disablenetwork yet.)

Let's keep working on it.

Michael

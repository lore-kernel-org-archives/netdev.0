From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 11 Jan 2010 09:58:52 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1001110929310.25601@tundra.namei.org>
References: <20100110215409.GA3705@heat>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
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
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-15?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
	Al Viro <viro@ZenIV.linux.org.uk
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100110215409.GA3705@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Jan 2010, Michael Stone wrote:

> 
> Pavel's position is that disablenetwork is likely to permit some attacker
> somewhere to deny network access to some setuid app some day in a way that
> violates some security policy.
> 
> He has mentioned specific concern over scenarios like:
> 
>   Alice configures PAM auth to 'fail open' by checking login credentials
>   against a restrictive LDAP server and, if the server is unavailable, against
>   a very permissive files database.
> 
>   Alice updates her kernel to a version with disablenetwork.
> 
>   Mallory calls disablenetwork, calls su -, and vanquishes all.
> 
> My position is that better isolation facilities like disablenetwork will
> prevent far more grievous security faults than they (theoretically) cause.
> 
> What is your perspective on the matter?

Unexpected failure modes for privileged apps using security interfaces has 
already proven to be a problem (e.g. the sendmail capabilities bug), so it 
seems prudent to try and mitigate that as well. I don't think we need to 
look at this as an either-or situation -- it seems we can do both, and get 
something useful in its own right from the mitigation.


-- 
James Morris
<jmorris@namei.org>

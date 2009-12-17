From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Thu, 17 Dec 2009 18:52:31 +0100
Message-ID: <20091217175230.GK9804@basil.fritz.box>
References: <20091213034418.GA4416@heat> <m1ljh7jijk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1ljh7jijk.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Solve that with an unused uid.  That ptrace_may_access check is
> completely non-intuitive, and a problem if we ever remove the current
> == task security module bug avoidance.

I thought he wanted to do that without suid?

If he can change uids he can as well just use full network namespaces.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

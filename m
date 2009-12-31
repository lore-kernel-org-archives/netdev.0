From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Thu, 31 Dec 2009 17:06:41 +0000
Message-ID: <20091231170641.6dd46c6e@lxorguk.ukuu.org.uk>
References: <m1iqbpwjtp.fsf@fess.ebiederm.org>
	<551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<20091230183513.GC14493@us.ibm.com>
	<m1fx6suswz.fsf@fess.ebiederm.org>
	<20091230201712.GA23999@us.ibm.com>
	<m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
	<20091230212931.233003b9@lxorguk.ukuu.org.uk>
	<m1skasrvnq.fsf@fess.ebiederm.org>
	<20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
	<m2bphfti1u.fsf@ssh.synack.fr>
	<e7d8f83e0912310608j2c52acabxbd57d24e2b3073ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Samir Bellabes <sam@synack.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
	Bryan Donlan <bdonlan@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura
To: Peter Dolding <oiaohm@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752832AbZLaRGN@vger.kernel.org>
In-Reply-To: <e7d8f83e0912310608j2c52acabxbd57d24e2b3073ca@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Lets step back for a moment.  What is the common issue with both.
> 
> The issue is simple.  "How to I generically tell the secuirty system
> want particular restrictions."

You don't. It's not "the security system", its a whole collection of
completely different models of security and differing tools.

> There is no generic LSM API for application or users to talk to the
> LSM and say I want the following restricted.

That's a meaningless observation I think because security doesn't work
that way. Removing specific features from a specific piece of code
generally isn't a security feature - its only meaningful in the context
of a more general policy and that policy expression isn't generic.

> To control the LSM the applications are expected to know what the LSM.
>  This has caused items like chrome major issues.

..

> Application does not need to be informed what is disabled from it.

So why does it cause chrome problems ?


There are multiple security models because nobody can agree on what they
should look like, just like multiple desktops. Each of them is based on a
totally different conceptual model so the idea of a single interface to
them is a bit meaningless.

Alan

From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 17:40:10 -0500
Message-ID: <20100110224010.GA3825@heat>
References: <20100110215848.GA26609@elf.ucw.cz>
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
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:58549 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753955Ab0AJWhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jan 2010 17:37:51 -0500
Content-Disposition: inline
In-Reply-To: <20100110215848.GA26609@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek wrote:

> You can trivialy make disablenetwork disable setuid exec, too. That
> will introduce better isolation facilities, but not introduce any new
> security problems.
> 
> For some reason, you don't want to do the obviously right thing.

I don't want to do it because it's not "obviously right" to me: I *have* setuid
programs that I want to be able to raise privileges when network-disabled.
I *don't have* any setuid programs that will be harmed by disablenetwork.

Examples of software that I want to be able to gain privileges normally include:

   rainbow, which requires privilege in order to add new accounts to the system
   and in order to call setuid() but which does not require networking
   privileges.

   qmail-queue, which uses setuid to deliver mail that it reads from fd 0 to
   local users

   and other old favorites like mount, fusermount, X, and, presumably, any audio
   software that wants to go realtime.

Kind regards,

Michael

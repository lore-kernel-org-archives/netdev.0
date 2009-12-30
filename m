From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Unprivileged: Disable acquisition of privileges
Date: Tue, 29 Dec 2009 20:33:10 -0800
Message-ID: <m1r5qdt721.fsf@fess.ebiederm.org>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com>
	<3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<m3oclhzgm4.fsf@ursa.amorsen.dk> <m17hs5y0mg.fsf@fess.ebiederm.org>
	<20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
	<m1iqbpwjtp.fsf@fess.ebiederm.org> <20091229223631.GB22578@us.ibm.com>
	<m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	<3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
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
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>,
To: Bryan Donlan <bdonlan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751900AbZL3EdR@vger.kernel.org>
In-Reply-To: <3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com> (Bryan Donlan's message of "Tue\, 29 Dec 2009 22\:54\:59 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bryan Donlan <bdonlan@gmail.com> writes:

> Is this sufficient for other security models such as selinux or
> TOMOYO? Can processes in these models gain privileges through means
> not restricted here?

The LSM is primarily about returning -EPERM more often.
Except for the prctl and the capability hooks I am not aware
of anywhere a LSM can increase a processes capabilities.

> Also, perhaps there should be a corresponding GET prctl?

Probably for the final version.

Eric

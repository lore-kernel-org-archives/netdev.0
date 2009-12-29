From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 12:40:55 -0800
Message-ID: <m17hs5y0mg.fsf@fess.ebiederm.org>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com>
	<3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<m3oclhzgm4.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Donlan <bdonlan@gmail.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Michael Stone <michael@laptop.org>,
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
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al Viro
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m3oclhzgm4.fsf@ursa.amorsen.dk> (Benny Amorsen's message of "Tue\, 29 Dec 2009 21\:10\:11 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benny Amorsen <benny+usenet@amorsen.dk> writes:

> Bryan Donlan <bdonlan@gmail.com> writes:
>
>> I, for one, think it would be best to handle it exactly like the
>> nosuid mount option - that is, pretend the file doesn't have any
>> setuid bits set. There's no reason to deny execution; if the process
>> would otherwise be able to execute it, it can also copy the file to
>> make a non-suid version and execute that instead.
>
> Execute != read. The executable file may contain secrets which must not
> be available to the user running the setuid program. If you fail the
> setuid, the user will be able to ptrace() and then the secret is
> revealed.
>
> It's amazing how many security holes appear from what seems like a very
> simple request.

Do we have a security hole in nosuid mount option?
Can someone write a patch to fix it?

Eric

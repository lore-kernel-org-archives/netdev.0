From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Fri, 1 Jan 2010 11:28:41 +0100
Message-ID: <20100101102841.GA22924@atrey.karlin.mff.cuni.cz>
References: <3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com> <m1r5qdt721.fsf@fess.ebiederm.org> <3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com> <m1d41w62zc.fsf_-_@fess.ebiederm.org> <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com> <20091230183513.GC14493@us.ibm.com> <m1fx6suswz.fsf@fess.ebiederm.org> <20091230201712.GA23999@us.ibm.com> <m1hbr8tb8q.fsf_-_@fess.ebiederm.org> <20091230212931.233003b9@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
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
	=?iso-8859-2?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@s
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091230212931.233003b9@lxorguk.ukuu.org.uk>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Added bprm->nosuid to make remove the need to add
> > duplicate error prone checks.  This ensures that
> > the disabling of suid executables is exactly the
> > same as MNT_NOSUID.
> 
> Another fine example of why we have security hooks so that we don't get a
> kernel full of other "random security idea of the day" hacks.

well... new unshare functionality depends on this. if unshare is
important enough, this may not be lsm.

(and disablenetwork *should* depend on this)
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

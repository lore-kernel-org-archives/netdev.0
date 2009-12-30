From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Wed, 30 Dec 2009 12:00:45 -0600
Message-ID: <20091230180045.GA14493@us.ibm.com>
References: <20091229151146.GA32153@us.ibm.com>
 <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
 <m3oclhzgm4.fsf@ursa.amorsen.dk>
 <m17hs5y0mg.fsf@fess.ebiederm.org>
 <20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
 <m1iqbpwjtp.fsf@fess.ebiederm.org>
 <20091229223631.GB22578@us.ibm.com>
 <m1zl51uoqd.fsf@fess.ebiederm.org>
 <20091230035008.GA6819@us.ibm.com>
 <m11vidulsq.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Bryan Donlan <bdonlan@gmail.com>,
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
	Pavel Machek <pavel@ucw.cz>, Al V
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m11vidulsq.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> 
> >> In common cap we drop the new capabilities if we are being ptraced.
> >> Look for brm->unsafe.
> >
> > Yes - that isn't the issue.
> 
> Right.  Sorry.  I saw that we set unsafe and totally
> missed that we don't act on it in that case.
> 
> > It goes back to finding a way to figure out what is inside the
> > file when the installer obviously thought we shouldn't be able
> > to read the file.
> >
> > Do we care?  <shrug>
> 
> <shrug>
> 
> I expect two lines of testing bprm->unsafe and failing
> at the right point would solve that. 

But what is the right response?  Prevent excecution?  Stop the
tracer?  Enter some one-shot mode where the whole exec appears
as one step, but tracing continues if execution continues on a
dumpable file?

-serge

From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 22:16:09 +0100
Message-ID: <20100110211609.GC26079@elf.ucw.cz>
References: <20091227010441.GA12077@heat>
 <20091227010650.GA12190@heat>
 <20091230185053.GB18712@us.ibm.com>
 <20100101143100.GA3944@atrey.karlin.mff.cuni.cz>
 <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
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
	Am?rico Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2010-01-11 08:11:55, James Morris wrote:
> On Fri, 1 Jan 2010, Pavel Machek wrote:
> 
> > > Quoting Michael Stone (michael@laptop.org):
> > > > Implement security_* hooks for socket_create, socket_bind, socket_connect,
> > > > socket_sendmsg, and ptrace_access_check which return -EPERM when called from a
> > > > process with networking restrictions. Exempt AF_UNIX sockets.
> > > > 
> > > > Signed-off-by: Michael Stone <michael@laptop.org>
> > > 
> > > Acked-by: Serge Hallyn <serue@us.ibm.com>
> > 
> > For the record: NAK, as it introduces security holes.
> 
> Please elaborate.

See the mailthread.

Allows user to disable suid program's access to network. That bypasses
audit, and will cause system-wide DoS if suid program decides to go
daemon.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

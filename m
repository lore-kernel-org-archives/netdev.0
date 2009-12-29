From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 12:56:44 -0800
Message-ID: <m1ws05wlbn.fsf@fess.ebiederm.org>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com>
	<3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<20091229163939.GA6984@us.ibm.com>
	<3e8340490912290901y60d7daf2w5778c25f44972955@mail.gmail.com>
	<m1fx6ty6ds.fsf@fess.ebiederm.org>
	<3e8340490912291108t7e000e75p8264fa585f831464@mail.gmail.com>
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
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@zeniv.linux.org.uk>
To: Bryan Donlan <bdonlan@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <3e8340490912291108t7e000e75p8264fa585f831464@mail.gmail.com> (Bryan Donlan's message of "Tue\, 29 Dec 2009 14\:08\:30 -0500")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bryan Donlan <bdonlan@gmail.com> writes:

> It's probably reasonable to require that real == effective == saved ==
> fs UID (and same for GID); anything else brings up sticky issues of
> "which UID is a higher capability?"
> If a process does this call, it's effectively saying that the only way
> it's going to be accessing resources beyond its current UID and
> capabilities is by talking to another process over a (unix domain)
> socket.

Makes sense.  Especially for the initial implementation,
and it keeps the code size small.

Eric


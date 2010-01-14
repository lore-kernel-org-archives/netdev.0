From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Thu, 14 Jan 2010 11:36:39 -0600
Message-ID: <20100114173639.GA15587@us.ibm.com>
References: <20100114164702.GA13439@us.ibm.com>
 <20100114171309.GA6372@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@ZenIV.linux.org.uk>,
	K
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100114171309.GA6372@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Michael Stone (michael@laptop.org):
> Quoting Michael Stone (michael@laptop.org):
> 
> >Ah - but I worry that if you do that Alan or others will object.  Where do
> >you plan to store the disablenet_allowed bit?
> 
> If using prctl directly, I would store the bit in the task->network bitfield
> introduced by the earlier patches.
> 
> >You can use security_prctl() to keep the code out of sys_prctl().
> 
> I don't understand this suggestion; can you clarify? (Also, for what it's
> worth: I intended to put the check for CAP_SETPCAP in prctl_set_network().)
> 
> >but you still have the question of whether you add a bit to the task struct,
> >use task->security and not stack with selinux, use a thread flag, or try to
> >enable stacking of task->security.
> 
> For this revision of the patch, I will use the same approach as the previous
> patches (conditionally compiled task->network).
> 
> Michael
> 
> P.S. - Patches to follow tonight or tomorrow.

Cool I'll just wait for the patches  :)

thanks,
-serge

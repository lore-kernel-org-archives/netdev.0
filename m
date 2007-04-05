From: Tom Rini <trini@kernel.crashing.org>
Subject: Re: [PATCH] netpoll: trapping fix/cleanup
Date: Wed, 4 Apr 2007 20:26:46 -0700
Message-ID: <20070405032646.GG22371@smtp.west.cox.net>
References: <200703302340.27343.sshtylyov@ru.mvista.com>
	<46130DD6.6050707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	mhuth@mvista.com, kgdb-bugreport@lists.sourceforge.net
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <46130DD6.6050707@pobox.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Sender: kgdb-bugreport-bounces@lists.sourceforge.net
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Apr 03, 2007 at 10:30:46PM -0400, Jeff Garzik wrote:
> Sergei Shtylyov wrote:
> > CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely bypassed in
> > the netpoll's "trapped" mode which easily causes overflows in the drivers with
> > short TX queues (most notably, in 8139too with its 4-deep queue).
> > Make this option more sensible by only bypassing TX softirq wakeup and remove
> > CONFIG_NETPOLL_RX option completely since there is *no* code depending on it.
> > 
> > Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> ACK but (a) DaveM not me should apply this, and (b) I would check with 
> netpoll people to see what that define is there for.

In terms of KGDB usage, I know Sergei has been trying to track down and
fix some issues (/make it more reliable) so if this does impact us I
know he'll be sending something along.  ACK.

-- 
Tom Rini

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

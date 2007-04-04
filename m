From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] netpoll: trapping fix/cleanup
Date: Tue, 03 Apr 2007 22:30:46 -0400
Message-ID: <46130DD6.6050707@pobox.com>
References: <200703302340.27343.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	mhuth@mvista.com, kgdb-bugreport@lists.sourceforge.net
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <200703302340.27343.sshtylyov@ru.mvista.com>
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

Sergei Shtylyov wrote:
> CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely bypassed in
> the netpoll's "trapped" mode which easily causes overflows in the drivers with
> short TX queues (most notably, in 8139too with its 4-deep queue).
> Make this option more sensible by only bypassing TX softirq wakeup and remove
> CONFIG_NETPOLL_RX option completely since there is *no* code depending on it.
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

ACK but (a) DaveM not me should apply this, and (b) I would check with 
netpoll people to see what that define is there for.

	Jeff




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 6/8] e1000e: convert ndev_ printks
	to	something smaller
Date: Mon, 31 Mar 2008 12:09:39 -0700
Message-ID: <1206990579.23161.32.camel@localhost>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>
	<20080328161531.6562.8515.stgit@localhost.localdomain>
	<47EDA38F.6080301@garzik.org>  <47F12F27.802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47F12F27.802@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2008-03-31 at 11:36 -0700, Kok, Auke wrote:
> yes and I even tried pushing for a generic netdev printk that incorporates the
> msg_enable bits properly
> 
> I also got absolutely unwelcome responses to that, if not none :)

http://www.mail-archive.com/netdev@vger.kernel.org/msg40070.html

It still makes sense to me.

I think the overall amount of churn is low,
readability would improve, existing errors in
msg_enable would be eliminated during the churn
and the newly introduced error rate would be lower.



-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace

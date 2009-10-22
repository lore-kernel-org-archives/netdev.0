From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 0/4] net: change the way mc_list
	is accessed
Date: Thu, 22 Oct 2009 15:51:21 +0200
Message-ID: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	mchehab@infradead.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	linux-media@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In a struct net_device, multicast addresses are stored using a self-made linked
list. To convert this to list_head list there would be needed to do the change
in all (literally all) network device drivers at once.

To solve this situation and also to make device drivers' code prettier I'm
introducing several multicast list helpers which can (and in the future they
should) be used to access mc list. Once all drivers will use these helpers,
we can easily convert to list_head.

The part of this patchset are also 3 examples of a usage of the helpers.

Kindly asking for review.

Thanks,

Jirka

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference

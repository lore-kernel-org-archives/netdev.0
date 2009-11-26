From: Simon Horman <horms@verge.net.au>
Subject: [rfc 0/3 v3] igb: bandwidth allocation
Date: Thu, 26 Nov 2009 11:05:38 +1100
Message-ID: <20091126000538.716725330@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net,
 netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

this series of patches exposes the bandwidth allocation hardware support of
the Intel 82576. It does so through a rather hackish sysfs entry. That
interface is just intended for testing so that the exposed hardware feature
can be exercised. I would like to find a generic way to expose this feature
to user-space.

v2
* Remove the patch "Initialise adapter->vfs_allocated_count in
  igb_init_vf()" as it causes a panic.

v3
* Incorporate several suggestions from Alexander Duyck
  as noted in the per-patch changelogs




------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july

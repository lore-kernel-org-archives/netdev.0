From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 0/5] iwlwifi: iwl3945 fix races,
	getting rid of sleep from context
Date: Wed,  9 Jan 2008 20:01:51 +0900
Message-ID: <11998765114113-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Joonwoo Park <joonwpark81@gmail.com>,
	ipw3945-devel@lists.sourceforge.net
To: Zhu Yi <yi.zhu@intel.com>, netdev@vger.kernel.org
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello,
This patchset does fix iwl3945's races and some other stuff.
For now it works for just iwl3945 but if some of them is needed for iwl4965, I would work for it.

patch against 2.6.24-rc7

[PATCH 1/5] iwlwifi: iwl3945 flush interrupt mask
[PATCH 2/5] iwlwifi: iwl3945 synchronize interrupt and tasklet for down iwlwifi
[PATCH 3/5] iwlwifi: iwl3945 fix oops while pci remove
[PATCH 4/5] iwlwifi: iwl3945 eliminate sleepable task queue from context
[PATCH 5/5] iwlwifi: iwl3945 switch private workqueue to ieee80211->workqueue

Thanks,
Joonwoo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace

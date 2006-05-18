From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Thu, 18 May 2006 13:28:49 -0400
Message-ID: <20060518172844.GC21325@tuxdriver.com>
References: <20060517193405.GB17895@tuxdriver.com> <20060517193801.GC17895@tuxdriver.com> <446B9456.5030308@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:36868 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932094AbWERR3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 May 2006 13:29:16 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <446B9456.5030308@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 17, 2006 at 10:23:34PM +0100, Daniel Drake wrote:
> John W. Linville wrote:
> >Daniel Drake:
> >      set_security implementation inside softmac
> 
> If it's not too late, can you drop this one?

Well, it's your patch.  If you want to withdraw it, I'll comply.

---

The following changes since commit 59d4b684fbe74b25ac8593f39d2aaa86aa485b1f:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Arjan van de Ven:
      unused exports in wireless drivers

 drivers/net/wireless/hostap/hostap_80211_tx.c |    1 -
 drivers/net/wireless/hostap/hostap_ap.c       |   11 -----------
 drivers/net/wireless/hostap/hostap_main.c     |    2 --
 3 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 06a5214..4a5be70 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -534,5 +534,4 @@ int hostap_master_start_xmit(struct sk_b
 }
 
 
-EXPORT_SYMBOL(hostap_dump_tx_80211);
 EXPORT_SYMBOL(hostap_master_start_xmit);
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 06c3fa3..ba13125 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -3276,17 +3276,6 @@ EXPORT_SYMBOL(hostap_init_data);
 EXPORT_SYMBOL(hostap_init_ap_proc);
 EXPORT_SYMBOL(hostap_free_data);
 EXPORT_SYMBOL(hostap_check_sta_fw_version);
-EXPORT_SYMBOL(hostap_handle_sta_tx);
-EXPORT_SYMBOL(hostap_handle_sta_release);
 EXPORT_SYMBOL(hostap_handle_sta_tx_exc);
-EXPORT_SYMBOL(hostap_update_sta_ps);
-EXPORT_SYMBOL(hostap_handle_sta_rx);
-EXPORT_SYMBOL(hostap_is_sta_assoc);
-EXPORT_SYMBOL(hostap_is_sta_authorized);
-EXPORT_SYMBOL(hostap_add_sta);
-EXPORT_SYMBOL(hostap_update_rates);
-EXPORT_SYMBOL(hostap_add_wds_links);
-EXPORT_SYMBOL(hostap_wds_link_oper);
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
-EXPORT_SYMBOL(hostap_deauth_all_stas);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 8dd4c44..93786f4 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -1125,11 +1125,9 @@ EXPORT_SYMBOL(hostap_set_auth_algs);
 EXPORT_SYMBOL(hostap_dump_rx_header);
 EXPORT_SYMBOL(hostap_dump_tx_header);
 EXPORT_SYMBOL(hostap_80211_header_parse);
-EXPORT_SYMBOL(hostap_80211_prism_header_parse);
 EXPORT_SYMBOL(hostap_80211_get_hdrlen);
 EXPORT_SYMBOL(hostap_get_stats);
 EXPORT_SYMBOL(hostap_setup_dev);
-EXPORT_SYMBOL(hostap_proc);
 EXPORT_SYMBOL(hostap_set_multicast_list_queue);
 EXPORT_SYMBOL(hostap_set_hostapd);
 EXPORT_SYMBOL(hostap_set_hostapd_sta);
-- 
John W. Linville
linville@tuxdriver.com

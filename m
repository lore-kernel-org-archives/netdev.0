From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: r8723au: Fix randconfig build errors
Date: Sat, 5 Apr 2014 21:09:36 -0700
Message-ID: <20140406040936.GA11608@kroah.com>
References: <1396756139-26286-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org,
 Jes Sorensen <Jes.Sorensen@redhat.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1396756139-26286-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 05, 2014 at 10:48:59PM -0500, Larry Finger wrote:
> The kbuild test robot got the following errors for i386-randconfig-c0-04060652:
> 
> ERROR: "wiphy_free" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "bridge_tunnel_header" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "ieee80211_frequency_to_channel" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_rx_mgmt" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "ieee80211_channel_to_frequency" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_mgmt_tx_status" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "rfc1042_header" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "__ieee80211_get_channel" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "wiphy_unregister" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_connect_result" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_michael_mic_failure" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_roamed" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_put_bss" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "wiphy_new" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "wiphy_register" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_inform_bss_width_frame" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_disconnected" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "ieee80211_amsdu_to_8023s" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> ERROR: "cfg80211_scan_done" [drivers/staging/rtl8723au/r8723au.ko] undefined!
> 
> All of these are fixed by forcing the selection of CFG80211 in Kconfig.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
> Cc: kbuild test robot <fengguang.wu@intel.com>

This should have been "Reported-by:"  I'll fix that up by hand...

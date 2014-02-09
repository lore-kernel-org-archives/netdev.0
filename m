From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/6] Various cleanups of r8188eu
Date: Sun,  9 Feb 2014 15:15:53 -0600
Message-ID: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

As has been noted, this driver is very rough. This set of patches is
intended to smooth some of the rough edges.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (6):
  staging: r8188eu: Replace wrapper around _rtw_memcmp()
  staging: r8188eu: Remove dead file
  staging: r8188eu: Remove some dead code from headers
  staging: r8188eu: Replace misspelled local container macro
  staging: r8188eu: Eliminate macro to get next list item
  staging: r8188eu: Remove _func_enter and _func_exit macros

 drivers/staging/rtl8188eu/Makefile                 |   1 -
 drivers/staging/rtl8188eu/core/rtw_ap.c            |  64 +++---
 drivers/staging/rtl8188eu/core/rtw_cmd.c           | 114 +----------
 drivers/staging/rtl8188eu/core/rtw_debug.c         |   6 +-
 drivers/staging/rtl8188eu/core/rtw_ieee80211.c     |  55 ++----
 drivers/staging/rtl8188eu/core/rtw_io.c            |  28 ---
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c     |  31 +--
 drivers/staging/rtl8188eu/core/rtw_mlme.c          | 218 ++++-----------------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c      |  90 ++++-----
 drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c      |  78 --------
 drivers/staging/rtl8188eu/core/rtw_p2p.c           |  50 ++---
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c       |  25 ---
 drivers/staging/rtl8188eu/core/rtw_recv.c          | 159 ++++++---------
 drivers/staging/rtl8188eu/core/rtw_security.c      |  75 +------
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c       |  78 +++-----
 drivers/staging/rtl8188eu/core/rtw_wlan_util.c     |  44 ++---
 drivers/staging/rtl8188eu/core/rtw_xmit.c          | 107 +++-------
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     |   4 +-
 drivers/staging/rtl8188eu/hal/hal_intf.c           |   4 -
 drivers/staging/rtl8188eu/hal/odm.c                |   4 +-
 drivers/staging/rtl8188eu/hal/odm_interface.c      |  34 ----
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c       |  12 --
 drivers/staging/rtl8188eu/hal/rtl8188e_dm.c        |   2 -
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c  |   3 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c        |   4 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c    |   4 +-
 drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c     |   6 +-
 drivers/staging/rtl8188eu/hal/usb_halinit.c        |  10 -
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c      |  23 +--
 drivers/staging/rtl8188eu/include/ioctl_cfg80211.h | 107 ----------
 drivers/staging/rtl8188eu/include/osdep_service.h  |  10 -
 drivers/staging/rtl8188eu/include/rtw_debug.h      |  14 --
 drivers/staging/rtl8188eu/include/rtw_io.h         |  44 -----
 drivers/staging/rtl8188eu/include/rtw_ioctl.h      |   2 -
 drivers/staging/rtl8188eu/include/rtw_mlme.h       |  32 ---
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c     | 136 ++++---------
 drivers/staging/rtl8188eu/os_dep/mlme_linux.c      |   9 +-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c        |   4 -
 drivers/staging/rtl8188eu/os_dep/osdep_service.c   |  10 -
 drivers/staging/rtl8188eu/os_dep/recv_linux.c      |   7 +-
 drivers/staging/rtl8188eu/os_dep/rtw_android.c     |   1 -
 drivers/staging/rtl8188eu/os_dep/usb_intf.c        |  14 --
 drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c   |   5 -
 drivers/staging/rtl8188eu/os_dep/xmit_linux.c      |  15 +-
 44 files changed, 360 insertions(+), 1383 deletions(-)
 delete mode 100644 drivers/staging/rtl8188eu/hal/odm_interface.c
 delete mode 100644 drivers/staging/rtl8188eu/include/ioctl_cfg80211.h

-- 
1.8.4.5

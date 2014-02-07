From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/12] Remove several pointless wrapper routines
Date: Thu,  6 Feb 2014 20:45:35 -0600
Message-ID: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
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

The driver contains a large number of wrapper routines. None of them are
needed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry Finger (12):
  staging: r8188eu: Remove ODM_Read1Byte
  staging: r8188eu: Remove ODM_Read2Byte
  staging: r8188eu: Remove ODM_Read4Byte
  staging: r8188eu: Remove ODM_Write1Byte
  staging: r8188eu: Remove ODM_Write2Byte
  staging: r8188eu: Remove ODM_Write4Byte
  staging: r8188eu: Remove wrappers around vmalloc and vzalloc
  staging: r8188eu: Remove wrappers around vfree
  staging: r8188eu: Remove ODM_AllocateMemory
  staging: r8188eu: Remove ODM_CompareMemory
  staging: r8188eu: Remove ODM_SetTimer
  staging: r8188eu: Remove ODM_InitializeTimer

 drivers/staging/rtl8188eu/core/rtw_mlme.c          |  9 ++-
 drivers/staging/rtl8188eu/core/rtw_mp.c            |  4 +-
 drivers/staging/rtl8188eu/core/rtw_recv.c          |  4 +-
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c       |  4 +-
 drivers/staging/rtl8188eu/core/rtw_xmit.c          | 14 ++---
 .../staging/rtl8188eu/hal/Hal8188ERateAdaptive.c   | 13 +++--
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     | 37 ++++++------
 drivers/staging/rtl8188eu/hal/odm.c                | 11 ++--
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |  4 +-
 drivers/staging/rtl8188eu/hal/odm_interface.c      | 67 ----------------------
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c  |  4 +-
 drivers/staging/rtl8188eu/include/odm_interface.h  | 23 --------
 drivers/staging/rtl8188eu/include/osdep_service.h  |  6 --
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c     |  6 +-
 drivers/staging/rtl8188eu/os_dep/osdep_service.c   | 25 +-------
 drivers/staging/rtl8188eu/os_dep/usb_intf.c        |  4 +-
 16 files changed, 59 insertions(+), 176 deletions(-)

-- 
1.8.4.5

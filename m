From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 0/7] rtlwifi: debug macros and uses neatening
Date: Thu, 05 Jan 2012 13:03:49 -0600
Message-ID: <4F05F415.2080803@lwfinger.net>
References: <cover.1325734202.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1325734202.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/04/2012 09:40 PM, Joe Perches wrote:
> Shrinks the objects a fair bit too.
>
> Joe Perches (7):
>    rtlwifi: Neaten RT_ASSERT, RT_TRACE, RTPRINT, RT_PRINT_DATA macros
>    rtlwifi: Standardize RT_PRINT_DATA macro and uses
>    rtlwifi: Convert RT_TRACE macro to use ##__VA_ARGS__
>    rtlwifi: Convert RTPRINT macro to use ##__VA_ARGS__
>    rtlwifi: Convert RT_ASSERT macro to use ##__VA_ARGS__
>    rtlwifi: Remove duplicate __func__
>    rtlwifi: Optimize RT_TRACE macro use of KBUILD_MODNAME for size
>
>   drivers/net/wireless/rtlwifi/base.c                |   56 +-
>   drivers/net/wireless/rtlwifi/cam.c                 |   81 ++--
>   drivers/net/wireless/rtlwifi/core.c                |  124 ++--
>   drivers/net/wireless/rtlwifi/debug.h               |   85 ++--
>   drivers/net/wireless/rtlwifi/efuse.c               |   61 +-
>   drivers/net/wireless/rtlwifi/pci.c                 |  211 +++----
>   drivers/net/wireless/rtlwifi/ps.c                  |   31 +-
>   drivers/net/wireless/rtlwifi/rc.c                  |    2 +-
>   drivers/net/wireless/rtlwifi/regd.c                |   12 +-
>   drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  189 +++---
>   drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   84 ++--
>   drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  211 +++---
>   drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |   24 +-
>   drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  262 ++++----
>   drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |   16 +-
>   drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |  108 ++--
>   drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |   83 ++--
>   drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    8 +-
>   drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   23 +-
>   drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |   24 +-
>   drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |  257 ++++----
>   drivers/net/wireless/rtlwifi/rtl8192cu/led.c       |   15 +-
>   drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |  105 ++--
>   drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |  121 ++--
>   drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   71 +-
>   drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    6 +-
>   drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   42 +-
>   drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |  239 +++----
>   drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |  117 ++--
>   drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |  188 +++---
>   drivers/net/wireless/rtlwifi/rtl8192de/led.c       |   14 +-
>   drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |  682 ++++++++++----------
>   drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |   95 ++--
>   drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    8 +-
>   drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   26 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   30 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |   66 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  244 ++++----
>   drivers/net/wireless/rtlwifi/rtl8192se/led.c       |   15 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |  204 +++---
>   drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |   60 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    8 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   18 +-
>   drivers/net/wireless/rtlwifi/usb.c                 |   39 +-
>   44 files changed, 2084 insertions(+), 2281 deletions(-)

All 7 are

ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry

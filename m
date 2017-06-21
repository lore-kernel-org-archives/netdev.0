From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 0/5] rtlwifi: Neatening
Date: Wed, 21 Jun 2017 13:12:44 -0500
Message-ID: <dca44694-9628-c7da-9f5e-426018f97e3b@lwfinger.net>
References: <cover.1497903396.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497903396.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/19/2017 03:18 PM, Joe Perches wrote:
> Joe Perches (5):
>    rtlwifi: Use temporary ops variable to reduce code size
>    rtlwifi: Use temporary variable btc_ops for rtlpriv->btcoexist.btc_ops
>    rtlwifi: Add and use convenience macro rtl_btc
>    realtek: btcoexist: Make the rtl_btc_ops struct const
>    realtek: rtlwifi: drivers: Use the rtl_btc convenience macro
> 
>   drivers/net/wireless/realtek/rtlwifi/base.c        |  46 ++--
>   .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.c   |   4 +-
>   .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.h   |   2 +-
>   drivers/net/wireless/realtek/rtlwifi/core.c        | 189 ++++++++--------
>   drivers/net/wireless/realtek/rtlwifi/efuse.c       |   9 +-
>   drivers/net/wireless/realtek/rtlwifi/pci.c         | 242 +++++++++++----------
>   drivers/net/wireless/realtek/rtlwifi/ps.c          |  83 +++----
>   .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |   3 +-
>   .../wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c   |   4 +-
>   .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |   3 +-
>   .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   3 +-
>   .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |   6 +-
>   .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   3 +-
>   drivers/net/wireless/realtek/rtlwifi/usb.c         |  40 ++--
>   drivers/net/wireless/realtek/rtlwifi/wifi.h        |   9 +-
>   15 files changed, 336 insertions(+), 310 deletions(-)
> 

Joe,

In general, I approve of your patches. Unfortunately, they will conflict with a 
number of changes that I am currently making. If you would like, I can merge 
your patches, fix the conflicts, and submit a version 2 for you.

Larry

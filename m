From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: Convert printks to pr_<level>
Date: Wed, 20 Jul 2011 17:45:39 -0500
Message-ID: <4E275A93.4050705@lwfinger.net>
References: <b57f00fc1d0947443aa1830c11c288e78924af44.1311177059.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b57f00fc1d0947443aa1830c11c288e78924af44.1311177059.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2011 10:51 AM, Joe Perches wrote:
> Use the current logging styles.
> Add pr_fmt where appropriate.
> Remove now unnecessary prefixes from printks.
> Convert hard coded prefix to __func__.
> Add a missing "\n" to a format.
>
> Signed-off-by: Joe Perches<joe@perches.com>
> ---
>   drivers/net/wireless/rtlwifi/base.c               |    9 ++-
>   drivers/net/wireless/rtlwifi/cam.c                |    4 +-
>   drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |    5 +-
>   drivers/net/wireless/rtlwifi/rtl8192cu/hw.c       |   69 ++++++++------------
>   drivers/net/wireless/rtlwifi/rtl8192cu/mac.c      |   11 ++-
>   drivers/net/wireless/rtlwifi/rtl8192de/sw.c       |    8 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/hw.c       |   10 ++--
>   drivers/net/wireless/rtlwifi/rtl8192se/phy.c      |    5 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/rf.c       |    4 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/sw.c       |    6 +-
>   drivers/net/wireless/rtlwifi/usb.c                |   12 ++--
>   11 files changed, 72 insertions(+), 71 deletions(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
> index bc13533..d88e405 100644
> --- a/drivers/net/wireless/rtlwifi/base.c
> +++ b/drivers/net/wireless/rtlwifi/base.c
> @@ -27,6 +27,8 @@
>    *
>    *****************************************************************************/

ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

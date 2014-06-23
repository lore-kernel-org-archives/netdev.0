From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCHv3 0/6] rtlwifi: Fix incorrect MSR mask
Date: Tue, 24 Jun 2014 00:26:56 +0200
Message-ID: <2124336.rxQ7Vr5PF1@al>
References: <1403560098-7520-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403560098-7520-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 23 June 2014 23:48:16 Rickard Strandqvist wrote:
> An error was found in many rtlwifi drivers where an invalid mask was used,
> (bt_msr & 0xfc) will never match 0x3. This has been corrected by supplying
> a valid mask as a macro. Drivers which did not have this bug are still
> modified for consistency.

LGTM for all 6 patches. Reviewed-by was added with permission in a
private conversation.

> Rickard Strandqvist (1):
>   rtlwifi: Fix media status register mask AND Replace magic number by macro

This looks a bit unfortunate, next time just wipe old patches and
generate new ones with git-format-patch, then use the command
git-send-email patches/*. In that way, the threading stays intact.

Kind regards,
Peter

>  drivers/net/wireless/rtlwifi/rtl8188ee/hw.c  |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8188ee/reg.h |    1 +
>  drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/reg.h |    1 +
>  drivers/net/wireless/rtlwifi/rtl8192cu/hw.c  |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/hw.c  |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/reg.h |    1 +
>  drivers/net/wireless/rtlwifi/rtl8723ae/hw.c  |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8723ae/reg.h |    1 +
>  drivers/net/wireless/rtlwifi/rtl8723be/hw.c  |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8723be/reg.h |    1 +
>  drivers/staging/rtl8821ae/rtl8821ae/hw.c     |    2 +-
>  drivers/staging/rtl8821ae/rtl8821ae/reg.h    |    1 +
>  13 files changed, 13 insertions(+), 7 deletions(-)

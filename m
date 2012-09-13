From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [RFC/RFT 14/15] rtlwifi: Modify files for addition of rtl8723ae
Date: Thu, 13 Sep 2012 13:11:58 +1000
Message-ID: <CAGRGNgWezEzXV0-k6DA7TckNpa=zgN6LNv898N-PRU6P1LYgOw@mail.gmail.com>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net> <1347483294-6943-15-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, chaoming_li@realsil.com.cn
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40503 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab2IMDMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 23:12:20 -0400
In-Reply-To: <1347483294-6943-15-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Larry,

On Thu, Sep 13, 2012 at 6:54 AM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> This patch modifies the files of rtlwifi for the addition of a new driver
> to handle the Realtek RTL8723AE wireless device, and introduces a new
> routine to maintaim statistics that will be used later for roaming.
>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: <chaoming_li@realsil.com.cn>
> ---
>  drivers/net/wireless/rtlwifi/debug.h |    2 +
>  drivers/net/wireless/rtlwifi/pci.h   |    1 +
>  drivers/net/wireless/rtlwifi/stats.c |  274 ++++++++++++++++++++++++++++++++++
>  drivers/net/wireless/rtlwifi/stats.h |   47 ++++++
>  4 files changed, 324 insertions(+)
>  create mode 100644 drivers/net/wireless/rtlwifi/stats.c
>  create mode 100644 drivers/net/wireless/rtlwifi/stats.h
>
> diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
> index 07493d2..b81e299 100644
> --- a/drivers/net/wireless/rtlwifi/debug.h
> +++ b/drivers/net/wireless/rtlwifi/debug.h
> @@ -106,6 +106,8 @@
>  #define COMP_REGD                      BIT(27)
>  #define COMP_CHAN                      BIT(28)
>  #define COMP_USB                       BIT(29)
> +#define COMP_EASY_CONCURRENT           BIT(29)

Is this supposed to be bit #29 - I notice that COMP_USB is also bit 29.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/

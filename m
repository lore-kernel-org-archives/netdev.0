From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v1] NFC: Add nfc_dbg() macro
Date: Sun, 26 Mar 2017 15:37:01 +0300
Message-ID: <1490531821.708.7.camel@linux.intel.com>
References: <20170322192251.30261-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>,
        linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:28143 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751309AbdCZMhG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Mar 2017 08:37:06 -0400
In-Reply-To: <20170322192251.30261-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-22 at 21:22 +0200, Andy Shevchenko wrote:
> In some cases nfc_dbg() is useful. Add such macro to a header.
> 

I think we may drop this, since the idea is to get rid of such macros
(as I read back in 2011 in commit message of change that removed
nfc_dbg() one).

I will re-do dependent series to not use it at all.

> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  include/net/nfc/nfc.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
> index 1a3de8b34ad2..bbdc73a3239d 100644
> --- a/include/net/nfc/nfc.h
> +++ b/include/net/nfc/nfc.h
> @@ -27,6 +27,7 @@
>  #include <linux/device.h>
>  #include <linux/skbuff.h>
>  
> +#define nfc_dbg(dev, fmt, ...) dev_dbg((dev), "NFC: " fmt,
> ##__VA_ARGS__)
>  #define nfc_info(dev, fmt, ...) dev_info((dev), "NFC: " fmt,
> ##__VA_ARGS__)
>  #define nfc_err(dev, fmt, ...) dev_err((dev), "NFC: " fmt,
> ##__VA_ARGS__)
>  

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy

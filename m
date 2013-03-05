From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] net/wireless/brcm80211: remove PCI_BUS define from defs.h
 to fix warnings
Date: Mon, 04 Mar 2013 19:28:08 -0600
Message-ID: <51354A28.3040607@lwfinger.net>
References: <1362445374.4591.28.camel@lorien2>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brudley@broadcom.com, arend@broadcom.com, frankyl@broadcom.com,
	linville@tuxdriver.com, seth.forshee@canonical.com,
	pieterpg@broadcom.com, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, shuahkhan@gmail.com
To: shuah.khan@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:34596 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932589Ab3CEB2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 20:28:13 -0500
In-Reply-To: <1362445374.4591.28.camel@lorien2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2013 07:02 PM, Shuah Khan wrote:
> PCI_BUS defined in defs.h results in warnings from all brcm80211 source files
> including defs.h. This define is not used in brcm80211. Removing this define
> fixes the warning.
>
> In file included from drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c:35:0:
> drivers/net/wireless/brcm80211/include/defs.h:23:0: warning: "PCI_BUS" redefined [enabled by default]
> include/uapi/linux/pci.h:36:0: note: this is the location of the previous definition
>    CC [M]  drivers/net/wireless/b43legacy/dma.o
>    CC [M]  drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.o
>    CC [M]  drivers/net/wireless/b43legacy/pio.o
> In file included from drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c:29:0:
> drivers/net/wireless/brcm80211/include/defs.h:23:0: warning: "PCI_BUS" redefined [enabled by default]
> include/uapi/linux/pci.h:36:0: note: this is the location of the previous definition
> In file included from drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c:29:0:
> drivers/net/wireless/brcm80211/include/defs.h:23:0: warning: "PCI_BUS" redefined [enabled by default]
> include/uapi/linux/pci.h:36:0: note: this is the location of the previous definition

Strange, I do not see PCI_BUS defined anywhere in the include/ branch in either 
3.8 or 3.9. In addition, I don't get these warnings. What is different in your 
system?

Larry

>
> Signed-off-by: Shuah Khan <shuah.khan@hp.com>
> ---
>   drivers/net/wireless/brcm80211/include/defs.h |    1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/wireless/brcm80211/include/defs.h b/drivers/net/wireless/brcm80211/include/defs.h
> index fb7cbcf..3608436 100644
> --- a/drivers/net/wireless/brcm80211/include/defs.h
> +++ b/drivers/net/wireless/brcm80211/include/defs.h
> @@ -20,7 +20,6 @@
>   #include <linux/types.h>
>
>   #define	SI_BUS			0
> -#define	PCI_BUS			1
>   #define	PCMCIA_BUS		2
>   #define SDIO_BUS		3
>   #define JTAG_BUS		4
>

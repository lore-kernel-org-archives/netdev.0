From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 1/3] hci_usb: do not initialize static variables to 0
Date: Fri, 18 Apr 2008 23:04:57 +0200
Message-ID: <A7F393C1-AEAC-4BC5-B7A4-A9CC78179CDF@holtmann.org>
References: <200804182046.m3IKkp7P014625@imap1.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, pavel@ucw.cz, pavel@suse.cz
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45601 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762864AbYDRVFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 17:05:03 -0400
In-Reply-To: <200804182046.m3IKkp7P014625@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> hci_usb: do not initialize static variables to 0.
>
> Signed-off-by: Pavel Machek <pavel@suse.cz>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dave Young <hidave.darkstar@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
> drivers/bluetooth/hci_usb.c |   14 +++++++-------
> 1 file changed, 7 insertions(+), 7 deletions(-)
>
> diff -puN drivers/bluetooth/hci_usb.c~hci_usb-do-not-initialize- 
> static-variables-to-0 drivers/bluetooth/hci_usb.c
> --- a/drivers/bluetooth/hci_usb.c~hci_usb-do-not-initialize-static- 
> variables-to-0
> +++ a/drivers/bluetooth/hci_usb.c
> @@ -62,13 +62,13 @@
> #define URB_ZERO_PACKET 0
> #endif
>
> -static int ignore = 0;
> -static int ignore_dga = 0;
> -static int ignore_csr = 0;
> -static int ignore_sniffer = 0;
> -static int disable_scofix = 0;
> -static int force_scofix = 0;
> -static int reset = 0;
> +static int ignore;
> +static int ignore_dga;
> +static int ignore_csr;
> +static int ignore_sniffer;
> +static int disable_scofix;
> +static int force_scofix;
> +static int reset;

I know that some people don't like to do it and I agree, but in case  
of module parameters, I prefer to have them clearly indicate what the  
default value is. It is a lot easier to read for other people looking  
at the code. So that one is a NAK from my side.

Regards

Marcel


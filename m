From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.10-rc1 4/15] wireless/orinoco: Update orinoco changelog
 and module parameters
Date: Tue, 26 Oct 2004 15:36:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417EA736.9010602@pobox.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098816355.3663.50.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1098816355.3663.50.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> --- a/drivers/net/wireless/orinoco.h.4-module-params	2004-10-26 10:43:24.213428352 -0400
> +++ b/drivers/net/wireless/orinoco.h	2004-10-26 10:43:31.138375600 -0400
> @@ -14,6 +14,9 @@
>  #include <linux/netdevice.h>
>  #include <linux/wireless.h>
>  #include <linux/version.h>
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 4, 25)
> +#include <linux/moduleparam.h>
> +#endif
>  


this is for out-of-tree drivers and patches

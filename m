From: David Miller <davem@davemloft.net>
Subject: Re: Add missing license tag to nci.
Date: Wed, 11 Jul 2012 17:24:01 -0700 (PDT)
Message-ID: <20120711.172401.2279394394116582200.davem@davemloft.net>
References: <20120711183157.GA19417@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilane@ti.com,
	linux-wireless@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758512Ab2GLAYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 20:24:02 -0400
In-Reply-To: <20120711183157.GA19417@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 11 Jul 2012 14:31:57 -0400

> nci: module license 'unspecified' taints kernel.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

NFC patches go to linux-wireless, CC:'d

> diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
> index d560e6f..f18f207 100644
> --- a/net/nfc/nci/core.c
> +++ b/net/nfc/nci/core.c
> @@ -27,6 +27,7 @@
>  
>  #define pr_fmt(fmt) KBUILD_MODNAME ": %s: " fmt, __func__
>  
> +#include <linux/module.h>
>  #include <linux/types.h>
>  #include <linux/workqueue.h>
>  #include <linux/completion.h>
> @@ -878,3 +879,5 @@ static void nci_cmd_work(struct work_struct *work)
>  			  jiffies + msecs_to_jiffies(NCI_CMD_TIMEOUT));
>  	}
>  }
> +
> +MODULE_LICENSE("GPL");
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

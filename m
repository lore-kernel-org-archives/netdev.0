From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [7/14] Orinoco driver updates - use modern module_parm()
Date: Wed, 23 Feb 2005 23:35:35 -0500
Message-ID: <421D5997.5030002@pobox.com>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain> <20050224040024.GI32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>,
        Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: David Gibson <hermes@gibson.dropbear.id.au>
In-Reply-To: <20050224040024.GI32001@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Gibson wrote:
> Add descrptions to module parameters in the orinoco driver, and also
> add permissions to allow them to be exported in sysfs.
> 
> Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>
> 
> Index: working-2.6/drivers/net/wireless/orinoco.c
> ===================================================================
> --- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-02-10 13:19:14.000000000 +1100
> +++ working-2.6/drivers/net/wireless/orinoco.c	2005-02-10 13:24:03.000000000 +1100
> @@ -461,12 +461,14 @@
>  /* Level of debugging. Used in the macros in orinoco.h */
>  #ifdef ORINOCO_DEBUG
>  int orinoco_debug = ORINOCO_DEBUG;
> -module_param(orinoco_debug, int, 0);
> +module_param(orinoco_debug, int, 0644);
> +MODULE_PARM_DESC(orinoco_debug, "Debug level");
>  EXPORT_SYMBOL(orinoco_debug);
>  #endif

eventually it would be nice to support netif_msg_*

	Jeff

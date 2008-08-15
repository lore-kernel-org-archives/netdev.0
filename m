From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for August 15 (bnx2) [resend/lost]
Date: Fri, 15 Aug 2008 18:41:17 -0500 (CDT)
Message-ID: <21849002.1218843677714.JavaMail.oracle@acsmt301.oracle.com>
References: <20080815184032.3acd8032.sfr@canb.auug.org.au>
	<20080815084116.340ac526.randy.dunlap@oracle.com> <20080815.151715.111675039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080815.151715.111675039.davem@davemloft.net>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Original Message ---
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Fri, 15 Aug 2008 08:41:16 -0700
> 
> > When VLAN is not enabled, bnx2 build fails with:
> > 
> > drivers/net/bnx2.c: In function 'bnx2_rx_int':
> > drivers/net/bnx2.c:2959: error: dereferencing pointer to incomplete type
> > drivers/net/bnx2.c:2960: error: dereferencing pointer to incomplete type
> > make[2]: *** [drivers/net/bnx2.o] Error 1
> 
> Does this fix it for you?

Yes, it does.  Thanks.

> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index d454810..2486a65 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -35,8 +35,8 @@
>  #include <linux/time.h>
>  #include <linux/ethtool.h>
>  #include <linux/mii.h>
> -#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
>  #include <linux/if_vlan.h>
> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
>  #define BCM_VLAN 1
>  #endif
>  #include <net/ip.h>

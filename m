From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3] r8169: clean up
Date: Tue, 2 Nov 2004 20:27:46 +0100
Message-ID: <20041102192746.GB24860@electric-eye.fr.zoreil.com>
References: <200411021203.25100.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200411021203.25100.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
> Removal of some magic numbers, unnecessary double not, and addition of "link 
> down" notification.
> 
> Signed-off-by: Jon Mason <jdmason@us.ibm.com>
> 
> --- r8169.c     2004-11-02 10:37:31.035203120 -0600
> +++ r8169.c.latest      2004-11-02 10:44:01.367863536 -0600
[...]
> @@ -773,7 +775,7 @@ static void rtl8169_gset_tbi(struct net_
> 
>         status = RTL_R32(TBICSR);
>         cmd->advertising = (status & TBINwEnable) ?  ADVERTISED_Autoneg : 0;
> -       cmd->autoneg = !!(status & TBINwEnable);
> +       cmd->autoneg = status & TBINwEnable;
> 
>         cmd->speed = SPEED_1000;
>         cmd->duplex = DUPLEX_FULL; /* Always set */

drivers/net/*.c use 0/1 or AUTONEG_{EN/DIS}ABLE.

--
Ueimor

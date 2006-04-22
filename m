From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 2/5] s2io driver updates
Date: Sat, 22 Apr 2006 11:28:02 +0200
Message-ID: <20060422092802.GD26666@electric-eye.fr.zoreil.com>
References: <Pine.GSO.4.10.10604211903180.15266-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, alicia.pena@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:25749 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1750750AbWDVRR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 13:17:59 -0400
Received: from fr.zoreil.com (electric-eye.fr.zoreil.com [213.41.134.224])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k3M9Vhfl014163
	for <netdev@vger.kernel.org>; Sat, 22 Apr 2006 09:31:44 GMT
To: Ananda Raju <Ananda.Raju@neterion.com>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.10.10604211903180.15266-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju <Ananda.Raju@neterion.com> :
[...]
> Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
> ---
> diff -upNr perf_fixes/drivers/net/s2io.c dmesg_param_fixes/drivers/net/s2io.c
> --- perf_fixes/drivers/net/s2io.c	2006-04-13 08:02:56.000000000 -0700
> +++ dmesg_param_fixes/drivers/net/s2io.c	2006-04-13 09:08:22.000000000 -0700
[...]
> @@ -4626,6 +4633,45 @@ static int write_eeprom(nic_t * sp, int 
>  	return ret;
>  }
>  
> +static void s2io_vpd_read(nic_t *nic)
> +{
> +	u8 vpd_data[256],data;

You may consider removing vpd_data from the stack and kmallocing it.

-- 
Ueimor

From: "Ananda Raju" <ananda.raju@neterion.com>
Subject: RE: [patch 2/5] s2io driver updates
Date: Mon, 24 Apr 2006 11:20:49 -0700
Message-ID: <200604241821.k3OILsDr027225@guinness.s2io.com>
References: <20060422092802.GD26666@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<leonid.grossman@neterion.com>, <ravinandan.arakali@neterion.com>,
	<rapuru.sriram@neterion.com>, <alicia.pena@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:41101 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751089AbWDXSV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 14:21:57 -0400
To: "'Francois Romieu'" <romieu@fr.zoreil.com>
In-Reply-To: <20060422092802.GD26666@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

We will consider moving vpd_data out of stack. We will wait for few more
time for other review comment, and submit one more patch on top of 5th patch
addressing all review comments. 

If there are no further comments please apply the patches 1 to 5 and notify
us. We will submit one more patch which addressing all review comments. 

Thanks 
Ananda 
-----Original Message-----
From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
Sent: Saturday, April 22, 2006 2:28 AM
To: Ananda Raju
Cc: jgarzik@pobox.com; netdev@vger.kernel.org; leonid.grossman@neterion.com;
ravinandan.arakali@neterion.com; rapuru.sriram@neterion.com;
alicia.pena@neterion.com
Subject: Re: [patch 2/5] s2io driver updates

Ananda Raju <Ananda.Raju@neterion.com> :
[...]
> Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
> ---
> diff -upNr perf_fixes/drivers/net/s2io.c
dmesg_param_fixes/drivers/net/s2io.c
> --- perf_fixes/drivers/net/s2io.c	2006-04-13 08:02:56.000000000 -0700
> +++ dmesg_param_fixes/drivers/net/s2io.c	2006-04-13
09:08:22.000000000 -0700
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


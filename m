From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH] net: variables reach -1, but 0 tested
Date: Sat, 31 Jan 2009 12:35:12 -0800
Message-ID: <1233434112.5903.28.camel@desktop>
References: <498429AE.1080404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fifo99.com ([67.223.236.141]:33344 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbZAaUpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 15:45:25 -0500
In-Reply-To: <498429AE.1080404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-01-31 at 11:36 +0100, Roel Kluin wrote:

>  
> -	while (limit--) {
> +	while (--limit) {
>  		val = phy_read(phy, MII_BMCR);
>  		if (val >= 0 && (val & BMCR_RESET) == 0)
>  			break;

It looks like these are checked for <= to 0 , are these changes strictly
nessesary?

>  
>  	/* make sure EEPROM has finished loading before setting GPIO_CFG */
>  	timeout=1000;
> -	while ( timeout-- && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
> +	while ( --timeout && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
>  		udelay(10);

If your doing "timeOut" to "timeout" below may as well drop the space
above after the "(" ..


Daniel


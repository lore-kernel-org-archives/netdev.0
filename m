From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH UPDATE] Ethernet driver for EISA only SNI RM200/RM400 machines
Date: Wed, 27 Jun 2007 00:01:40 +0200
Message-ID: <20070626220140.GB11551@electric-eye.fr.zoreil.com>
References: <20070626205340.GB21014@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jgarzik@pobox.com
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59151 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757275AbXFZWFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2007 18:05:48 -0400
Content-Disposition: inline
In-Reply-To: <20070626205340.GB21014@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Bogendoerfer <tsbogend@alpha.franken.de> :
[...]
> diff --git a/drivers/net/sni_82596.c b/drivers/net/sni_82596.c
> new file mode 100644
> index 0000000..80e32ad
> --- /dev/null
> +++ b/drivers/net/sni_82596.c
[...]
> +static int __devinit sni_82596_probe(struct platform_device *dev)
> +{
[...]
> +	if (retval) {
> +		free_netdev(netdevice);
> +probe_failed:
> +		if (mpu_addr)
> +			iounmap(mpu_addr);
> +		if (ca_addr)
> +			iounmap(ca_addr);
> +		if (eth_addr)
                    ^^^
> +			iounmap(ca_addr);
                                ^^
-> typo

Please use plain goto with proper labels and remove the tests.

-- 
Ueimor

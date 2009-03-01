From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: read MAC address from EEPROM on init (2nd
	attempt)
Date: Sun, 1 Mar 2009 23:34:14 +0100
Message-ID: <20090301223414.GA25537@electric-eye.fr.zoreil.com>
References: <1235736790-11408-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33985 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758326AbZCAWbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 17:31:44 -0500
Content-Disposition: inline
In-Reply-To: <1235736790-11408-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
[...]
> I tested 5 systems each with different Realtek NICs and I didn't find any
> problem. AFAIK Francois's NICs also works fine.

Yes.

[...]
> +	/* read MAC address */
> +	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_MAC_ADDR);
> +	mac[0] = x & 0xff;
> +	mac[1] = x >> 8;
> +	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_MAC_ADDR + 1);
> +	mac[2] = x & 0xff;
> +	mac[3] = x >> 8;
> +	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_MAC_ADDR + 2);
> +	mac[4] = x & 0xff;
> +	mac[5] = x >> 8;

I would not had mind a loop here but it's otherwise fine.

Please apply.

-- 
Ueimor

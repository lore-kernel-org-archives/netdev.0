From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 0/2] Fixes for sierra_net driver
Date: Thu, 09 Feb 2017 16:42:12 -0500 (EST)
Message-ID: <20170209.164212.1577169073741493412.davem@davemloft.net>
References: <cad9ab0b146e4391a4c870290450214e@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cad9ab0b146e4391a4c870290450214e-cBaz+nnMw1+krInni0qv/15UTUQ924AY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stefan Brüns <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
Date: Wed, 8 Feb 2017 02:46:31 +0100

> When trying to initiate a dual-stack (ipv4v6) connection, a MC7710, FW
> version SWI9200X_03.05.24.00ap answers with an unsupported LSI. Add support
> for this LSI.
> Also the link_type should be ignored when going idle, otherwise the modem
> is stuck in a bad link state.
> Tested on MC7710, T-Mobile DE, APN internet.telekom, IPv4v6 PDP type. Both
> IPv4 and IPv6 connections work.
> 
> v2: Do not overwrite protocol field in rx_fixup
> v3: Remove leftover struct ethhdr *eth declaration

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

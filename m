From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sierra_net: Add support for IPv6 and Dual-Stack
 Link Sense Indications
Date: Tue, 07 Feb 2017 12:58:25 -0500 (EST)
Message-ID: <20170207.125825.646803866093568777.davem@davemloft.net>
References: <20170206202034.10962-1-stefan.bruens@rwth-aachen.de>
        <e854396b8b354f08ab42647417958079@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan.bruens@rwth-aachen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e854396b8b354f08ab42647417958079@rwthex-w2-b.rwth-ad.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Brüns <stefan.bruens@rwth-aachen.de>
Date: Mon, 6 Feb 2017 21:20:33 +0100

>  
>  	/* Validate the protocol  - only support UMTS for now */
> -	if (lsi->protocol != SIERRA_NET_PROTOCOL_UMTS) {
> +	if (lsi->protocol == SIERRA_NET_PROTOCOL_UMTS) {
 ...
> +	} else if (lsi->protocol == SIERRA_NET_PROTOCOL_UMTS_DS) {
> +		expected_length = SIERRA_NET_LSI_UMTS_DS_STATUS_LEN;

If you are now supporting more protocols, that comment is not correct
any longer.  You therefore need to update it or remove it.

Thanks.

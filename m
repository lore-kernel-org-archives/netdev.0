From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bnx2x: Fix link problem with some DACs
Date: Mon, 14 Jun 2010 23:07:28 -0700 (PDT)
Message-ID: <20100614.230728.189694464.davem@davemloft.net>
References: <1276511188.13056.26.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750855Ab0FOGHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:07:16 -0400
In-Reply-To: <1276511188.13056.26.camel@lb-tlvb-yanivr.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Mon, 14 Jun 2010 13:26:28 +0300

> -			/* Set 2-wire transfer rate to 400Khz since 100Khz
> -			is not operational */
> +			/* Set 2-wire transfer rate of SFP+ module EEPROM
> +			to 100Khz since some DACs(direct attached cables) do
> +			not work at 400Khz.*/

This is not the correct way to format a multi-line comment.
It should be:

			/* Set 2-wire transfer rate of SFP+ module EEPROM
			 * to 100Khz since some DACs(direct attached cables) do
			 * not work at 400Khz.
			 */

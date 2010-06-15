From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: RE: [net-next PATCH] bnx2x: Fix link problem with some DACs
Date: Mon, 14 Jun 2010 23:12:00 -0700
Message-ID: <41FDA5AFCC66094F83A3D9545495A2A410711A024D@SJEXCHCCR01.corp.ad.broadcom.com>
References: <1276511188.13056.26.camel@lb-tlvb-yanivr.il.broadcom.com>
 <20100614.230728.189694464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4637 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576Ab0FOGMO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:12:14 -0400
In-Reply-To: <20100614.230728.189694464.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure Dave,
I'll fix and send it again.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, June 15, 2010 9:07 AM
To: Yaniv Rosner
Cc: netdev@vger.kernel.org
Subject: Re: [net-next PATCH] bnx2x: Fix link problem with some DACs

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



From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] bnx2x: LSO code was broken on BE platforms
Date: Thu, 09 Dec 2010 20:50:16 -0800 (PST)
Message-ID: <20101209.205016.59681423.davem@davemloft.net>
References: <1291808589.30114.65.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756109Ab0LJEtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 23:49:49 -0500
In-Reply-To: <1291808589.30114.65.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Wed, 8 Dec 2010 13:43:09 +0200

> Make the LSO code work on BE platforms: parsing_data field of 
> a parsing BD (PBD) for 57712 was improperly composed which made FW read wrong 
> values for TCP header's length and offset and, as a result, the corresponding 
> PCI device was performing bad DMA reads triggering EEH.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/3] bnx2x: LSO code was broken on BE platforms
Date: Sun, 12 Dec 2010 15:03:46 -0800 (PST)
Message-ID: <20101212.150346.35036069.davem@davemloft.net>
References: <1292163105.20811.160.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41889
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752800Ab0LLXDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 18:03:18 -0500
In-Reply-To: <1292163105.20811.160.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 12 Dec 2010 16:11:45 +0200

> Make the LSO code work on BE platforms: parsing_data field of 
> a parsing BD (PBD) for 57712 was improperly composed which made FW read wrong 
> values for TCP header's length and offset and, as a result, the corresponding 
> PCI device was performing bad DMA reads triggering EEH.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.

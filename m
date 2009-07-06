From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bnx2x: Disable HC coalescing when setting timeout
 to zero.
Date: Sun, 05 Jul 2009 19:01:57 -0700 (PDT)
Message-ID: <20090705.190157.203781942.davem@davemloft.net>
References: <1246803492.1685.18.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com, fleitner@redhat.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35912
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126AbZGFCBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:01:50 -0400
In-Reply-To: <1246803492.1685.18.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Sun, 5 Jul 2009 17:18:12 +0300

> Problem reported by Flavio Leitner <fleitner@redhat.com>:
> When setting rx/tx coalescing timeout to the values less than 12 traffic was
> stopped.
> 
> The FW supports coalescing in 12us granularity, and so value of less then 12
> should be interpreted as disabling coalescing
> 
> Signed-off-by: Vlad Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 09/13] bnx2x: add pri_map module parameter
Date: Sat, 12 Nov 2011 00:50:29 -0500 (EST)
Message-ID: <20111112.005029.2184476880178665420.davem@davemloft.net>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
	<1320938054-31288-10-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab1KLFuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 00:50:32 -0500
In-Reply-To: <1320938054-31288-10-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Thu, 10 Nov 2011 17:14:10 +0200

> From: Ariel Elior <ariele@broadcom.com>
> 
> The optional parameter pri_map is used to map the
> skb->priority to a Class Of Service (CoS) in the HW.
> This 32 bit parameter is evaluated by the  driver as 8
> values of 4 bits each. Each nibble sets the desired
> HW queue number for that priority.
> 
> Also:
> on the 5771x family this feature is unavailable (a single COS services all).
> on the 57712 family two classes of service are available.
> on the 578xx family three classes of service are availabe.
> configuring  priorities to unavailable COSs will log an error and default to
> COS 0.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

You can't do driver specific things like this.

Make a generic facility that any driver can make use of, not just
your's.

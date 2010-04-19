From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] bnx2x: Set default value of num_queues to 1 on
 32-bit platforms
Date: Sun, 18 Apr 2010 21:10:23 -0700 (PDT)
Message-ID: <20100418.211023.104052199.davem@davemloft.net>
References: <1271602224.27235.199.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750704Ab0DSEKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 00:10:19 -0400
In-Reply-To: <1271602224.27235.199.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 18 Apr 2010 17:50:24 +0300

> The default was changed to save memory on 32bits systems.
> 
> Author: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

This is absolutely rediculious.

There is no reason in the world to restrict multiqueue to only 64-bit
systems.

If there is a memory allocation issue, fix that!  Is it vmalloc() space
usage?

You don't even describe what the hell the problem is, so nobody can
figure out _WHY_ you're making this change.  That's so incredibly
frustrating because it makes it impossible for anyone to sanely
evaluate the patch.

The more I read of this patch series, the more I am incredibly
disappointed with the poor quality of these changes.

This is the worst patch series submitted by Broadcom engieers,
ever!

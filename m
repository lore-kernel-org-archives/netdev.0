From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Increase max rx ring size from 1K to 2K
Date: Thu, 21 Oct 2010 03:13:26 -0700 (PDT)
Message-ID: <20101021.031326.39189506.davem@davemloft.net>
References: <1287448254-14173-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, jfeeney@redhat.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754593Ab0JUKND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:13:03 -0400
In-Reply-To: <1287448254-14173-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 18 Oct 2010 17:30:54 -0700

> A number of customers are reporting packet loss under certain workloads
> (e.g. heavy bursts of small packets) with flow control disabled.  A larger
> rx ring helps to prevent these losses.
> 
> No change in default rx ring size and memory consumption.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Acked-by: John Feeney <jfeeney@redhat.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Ok, since the new limit is not the default, applied.

Thanks for the explanation Michael.

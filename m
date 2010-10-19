From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Increase max rx ring size from 1K to 2K
Date: Tue, 19 Oct 2010 01:14:34 -0700 (PDT)
Message-ID: <20101019.011434.226774173.davem@davemloft.net>
References: <1287448254-14173-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, jfeeney@redhat.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933123Ab0JSIOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 04:14:11 -0400
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

I don't see how it's any better to queue things more deeply in
hardware, compared to simply using hardware flow control since that's
what it's for and makes the queuing happen in the networking stack of
the sender, in software, which in the end performs better and gives
better feedback to the source of the data.

These huge RX queue sizes are absolutely rediculious, and I've
complained about this before.

And instead of seeing less of this, I keep seeing more of this stuff.
Please exert some pushback on these folks who are doing such insane
things.

Thanks.

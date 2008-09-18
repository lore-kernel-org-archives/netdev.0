From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH 1/2]: softirq: Add support for triggering softirq work on  softirqs.
Date: Thu, 18 Sep 2008 06:35:42 +0200
Message-ID: <20080918043542.GJ20055@kernel.dk>
References: <20080917.193439.125137565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nickpiggin@yahoo.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:46612 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbYIREfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 00:35:44 -0400
Content-Disposition: inline
In-Reply-To: <20080917.193439.125137565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17 2008, David Miller wrote:
> 
> softirq: Add support for triggering softirq work on softirqs.
> 
> This is basically a genericization of Jens Axboe's block layer
> remote softirq changes.

Looks good Dave! One small comment - instead of using 32, how about just
adding a NR_SOFTIRQ at the bottom of the softirq enum and use that for
the softirq_work_list sizing?

Apart from that, you can add my Signed-off-by.

-- 
Jens Axboe


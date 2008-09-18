From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Wed, 17 Sep 2008 21:50:53 -0700 (PDT)
Message-ID: <20080917.215053.116422969.davem@davemloft.net>
References: <20080917.193439.125137565.davem@davemloft.net>
	<20080918043542.GJ20055@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nickpiggin@yahoo.com.au
To: jens.axboe@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35399
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750781AbYIREvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 00:51:07 -0400
In-Reply-To: <20080918043542.GJ20055@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Axboe <jens.axboe@oracle.com>
Date: Thu, 18 Sep 2008 06:35:42 +0200

> On Wed, Sep 17 2008, David Miller wrote:
> > 
> > softirq: Add support for triggering softirq work on softirqs.
> > 
> > This is basically a genericization of Jens Axboe's block layer
> > remote softirq changes.
> 
> Looks good Dave! One small comment - instead of using 32, how about just
> adding a NR_SOFTIRQ at the bottom of the softirq enum and use that for
> the softirq_work_list sizing?

Good idea.

> Apart from that, you can add my Signed-off-by.

Great, thanks for looking at this.

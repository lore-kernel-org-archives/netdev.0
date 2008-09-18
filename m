From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Thu, 18 Sep 2008 10:40:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809181033250.1034@wrl-59.cs.helsinki.fi>
References: <20080917.193439.125137565.davem@davemloft.net>
 <20080918043542.GJ20055@kernel.dk> <20080917.215053.116422969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens.axboe@oracle.com, Netdev <netdev@vger.kernel.org>,
	nickpiggin@yahoo.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39741 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbYIRHkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 03:40:09 -0400
In-Reply-To: <20080917.215053.116422969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Sep 2008, David Miller wrote:

> From: Jens Axboe <jens.axboe@oracle.com>
> Date: Thu, 18 Sep 2008 06:35:42 +0200
> 
> > On Wed, Sep 17 2008, David Miller wrote:
> > > 
> > > softirq: Add support for triggering softirq work on softirqs.
> > > 
> > > This is basically a genericization of Jens Axboe's block layer
> > > remote softirq changes.
> > 
> > Looks good Dave! One small comment - instead of using 32, how about just
> > adding a NR_SOFTIRQ at the bottom of the softirq enum and use that for
> > the softirq_work_list sizing?
> 
> Good idea.

I suppose you could add lkml too as Andrew might not be happy if this 
kind of thing gets done behind his back on netdev/net-next only 
(considering some past experience)? :-)

-- 
 i.

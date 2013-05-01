From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] netpoll: convert mutex into a semaphore
Date: Wed, 1 May 2013 15:34:12 -0400
Message-ID: <20130501193412.GA32690@hmsreliant.think-freely.org>
References: <20130429181322.GA27119@hmsreliant.think-freely.org>
 <1367336105-6275-1-git-send-email-nhorman@tuxdriver.com>
 <20130501.150059.785741895635621733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bvanassche@acm.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58995 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756545Ab3EATeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:34:20 -0400
Content-Disposition: inline
In-Reply-To: <20130501.150059.785741895635621733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 01, 2013 at 03:00:59PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 30 Apr 2013 11:35:05 -0400
> 
> > Bart Van Assche recently reported a warning to me:
>  ...
> > This resulted from my commit ca99ca14c which introduced a mutex_trylock
> > operation in a path that could execute in interrupt context.  When mutex
> > debugging is enabled, the above warns the user when we are in fact
> > exectuting in interrupt context
> > interrupt context.
> > 
> > After some discussion, It seems that a semaphore is the proper mechanism to use
> > here.  While mutexes are defined to be unusable in interrupt context, no such
> > condition exists for semaphores (save for the fact that the non blocking api
> > calls, like up and down_trylock must be used when in irq context).
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: Bart Van Assche <bvanassche@acm.org>
> 
> Neil this looks good to me so I'm going to toss it into my tree and queue
> it up for -stable too, thanks!
> 
Ok, cool deal.  Thanks!
Neil

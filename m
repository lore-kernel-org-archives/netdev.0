From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 1/9] atm: propagate signal changes via notifier
Date: Fri, 9 Jul 2010 16:04:08 +0900
Message-ID: <20100709070408.GE24576@verge.net.au>
References: <4C36C353.9080501@hiramoto.org>
 <20100708.233801.258129125.davem@davemloft.net>
 <20100709065012.GB24576@verge.net.au>
 <20100708.235314.241453003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: karl@hiramoto.org, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48876 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333Ab0GIHEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 03:04:12 -0400
Content-Disposition: inline
In-Reply-To: <20100708.235314.241453003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 08, 2010 at 11:53:14PM -0700, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Fri, 9 Jul 2010 15:50:13 +0900
> 
> > On Thu, Jul 08, 2010 at 11:38:01PM -0700, David Miller wrote:
> >> From: Karl Hiramoto <karl@hiramoto.org>
> >> Date: Fri, 09 Jul 2010 08:36:03 +0200
> >> 
> >> > Ok, fixing it,  but there are 100's of occurences in net/ like i had it. :-)
> >> 
> >> I would be happy to see a patch which fixes them up :-)
> > 
> > Really? By my calculations it would be an awful lot of churn.
> > 
> > $ find net/ -type f -name "*.[chS]" | xargs grep "\/\* *$" | wc -l
> > 6833
> > $ find net/ -type f -name "*.[chS]" | xargs grep -l "\/\* *$" | wc -l
> > 929
> 
> I didn't mean "one patch" which fixes them up :)
> 
> Done graudually in chunks over a period of time, it's not likely
> to be so much churn.
> 
> This is how every other coding style malfeasance gets handled.

Understood

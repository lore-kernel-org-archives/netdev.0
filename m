From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [net 5/6] i40e: better return values
Date: Tue, 24 Sep 2013 12:09:06 -0700
Message-ID: <20130924120906.00000efe@unknown>
References: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1380015910-25927-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<1380022486.3575.74.camel@joe-AO722>
	<20130924.101231.1193830264265403478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <joe@perches.com>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57794 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005Ab3IXTJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 15:09:07 -0400
In-Reply-To: <20130924.101231.1193830264265403478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Sep 2013 10:12:31 -0400
David Miller <davem@davemloft.net> wrote:
> > Ick.  post_increment problem.
> > 
> > 	return ++num_tc;
> > 
> > There's nothing wrong with the original code
> > unless this is a bugfix which should be documented
> > better than "better return values".
> 
> Agreed, this style of coding is asking for a bug.
> 
> If you want to return "num_tc PLUS ONE" just say that:
> 
> 	return num_tc + 1;

Oops! Obviously the original post-inc was not the intent. That was my
bad. good catch Joe! will fix and resubmit.

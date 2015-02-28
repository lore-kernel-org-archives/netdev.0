From: David Miller <davem@davemloft.net>
Subject: Re: [patch -mainline] niu: fix error handling in
 niu_class_to_ethflow()
Date: Sat, 28 Feb 2015 12:59:40 -0500 (EST)
Message-ID: <20150228.125940.2141368511096709635.davem@davemloft.net>
References: <20150226165656.GB6820@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benoit.taine@lip6.fr, fabf@skynet.be, bhelgaas@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbbB1R7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 12:59:42 -0500
In-Reply-To: <20150226165656.GB6820@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 26 Feb 2015 19:56:56 +0300

> There is a discrepancy here because the niu_class_to_ethflow() returns
> zero on failure and one on success but the caller expected zero on
> success and negative on failure.
> 
> The problem means that we allow the user to pass classes and flow_types
> which we don't want.  I've looked at it a bit and I don't see it as a
> very serious bug.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.

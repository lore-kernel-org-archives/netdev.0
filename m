From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: Fix unsigned function that is
 returning negative vals
Date: Sun, 22 Jan 2012 14:24:44 -0500 (EST)
Message-ID: <20120122.142444.234550384877909252.davem@davemloft.net>
References: <1327023606-24851-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab2AVTYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:24:47 -0500
In-Reply-To: <1327023606-24851-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 19 Jan 2012 20:40:06 -0500

> Every call to num_args() immediately checks the return value for
> less than zero, as it will return -EFAULT for a failed get_user()
> call.  So it makes no sense for the function to be declared as an
> unsigned long.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipconfig: add informative timeout messages
 while waiting for carrier
Date: Tue, 02 Apr 2013 14:35:56 -0400 (EDT)
Message-ID: <20130402.143556.1226949973977697625.davem@davemloft.net>
References: <1364911105-21734-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760612Ab3DBSf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:35:57 -0400
In-Reply-To: <1364911105-21734-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 2 Apr 2013 09:58:25 -0400

> Commit 3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c ("ipconfig wait
> for carrier") added a "wait for carrier on at least one interface"
> policy, with a worst case maximum wait of two minutes.
> 
> However, if you encounter this, you won't get any feedback from
> the console as to the nature of what is going on.  You just see
> the booting process hang for two minutes and then continue.
> 
> Here we add a message so the user knows what is going on, and
> hence can take action to rectify the situation (e.g. fix network
> cable or whatever.)  After the 1st 10s pause, output now begins
> that looks like this:
> 
> 	Waiting up to 110 more seconds for network.
> 	Waiting up to 100 more seconds for network.
> 	Waiting up to 90 more seconds for network.
> 	Waiting up to 80 more seconds for network.
> 	...
> 
> Since most systems will have no problem getting link/carrier in the
> 1st 10s, the only people who will see these messages are people with
> genuine issues that need to be resolved.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

This is fine, applied, thanks.

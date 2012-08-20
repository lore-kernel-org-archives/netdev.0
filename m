From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/9] tipc: misc updates for 3.7
Date: Mon, 20 Aug 2012 02:27:43 -0700 (PDT)
Message-ID: <20120820.022743.465143033806832968.davem@davemloft.net>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	ying.xue@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab2HTJ1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:27:44 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 16 Aug 2012 18:09:05 -0400

> This series gets some more largely trivial things out of
> the way.  Most interesting are:
> 
> 1) fix lockdep splat from bearer init by pushing the setup
>    off to schedule_work.
> 
> 2) simplification of configuration by removal of a couple of
>    tuning knobs which used to have low default values.
> 
> The remainder are largely innocuous, I think.  I did wonder
> if there was an alternate/better way to handle the splat though.
> 
> I've done my own local testing of this series on today's net-next
> commit 2ea214929d601 ("Merge branch 'for-davem' ... wireless-next")
> 
> I'll wait a couple of days to allow for any possible feedback and
> change requests, and then send a pull request after that.

All applied, thanks Paul.

It's less useful for you to build the GIT tree "later", at least for
me.

If the patches are good and there is no feedback asking for changes,
I want to be able to just pull them into my tree immediately as I
did here.

Thanks.

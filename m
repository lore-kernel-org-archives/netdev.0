From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/20] misc tipc updates / enhancements
Date: Fri, 24 Jun 2011 16:55:02 -0700 (PDT)
Message-ID: <20110624.165502.1719843876101837058.davem@davemloft.net>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626Ab1FXXzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 19:55:03 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 24 Jun 2011 18:07:07 -0400

> A bit more dead code removal, some collapsing of functions with
> too many arguments, and some cosmetic stuff with no real impact.
> 
> But I think the best part in this lot is getting rid of the internal
> (to tipc) duplication of "almost" linked list like code, and just
> having it use the normal shared kernel code for the task. 
> The diffstat summary reflects the net gain here:
> 
>        12 files changed, 276 insertions(+), 381 deletions(-)
> 
> All credit to Al for the work to get here.  I'm just an intermediate
> reviewer -- and happy to see my value-add in that role becoming smaller
> and smaller each time as tipc-2 leaves the SF tipc-1.7.x further behind.
> 
> I've independently tested using the basic tipcTS/tipcTC tests between
> an x86-32 and an x86-64 host, in both directions.

Pulled, thanks a lot.

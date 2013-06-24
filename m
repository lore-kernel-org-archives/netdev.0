From: David Miller <davem@davemloft.net>
Subject: Re: Reverts in "net" accidentally overwrote changes in "net-next"
Date: Mon, 24 Jun 2013 12:44:16 -0700 (PDT)
Message-ID: <20130624.124416.2047477142832668416.davem@davemloft.net>
References: <51C892B5.2020109@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab3FXToR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 15:44:17 -0400
In-Reply-To: <51C892B5.2020109@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 24 Jun 2013 14:40:53 -0400

> A build warning led me to notice this revert:
> 
>  ---------------
>  commit 7a1a0cbfeb31f20acc10722642198e76bbc30cb9
>  Author: David S. Miller <davem@davemloft.net>
>  Date:   Thu May 23 12:15:32 2013 -0700
> 
>     net: Revert unused variable changes.
>     
>     This reverts commits:
>     
>     c573972c111eb4c6b3f3250ad71e7c75cc799833
>     1a5904342c7380ceddd61c0b37544d752d0b1433
>     da2e2c214953f37c2a6be20226537ca5a329724c
>     
>     They were meant for net-next not net.
>  ---------------
> 
> It appears to have been merged forward into net-next, and now
> net-next has also lost the functional changes from them.

This should be fixed now.

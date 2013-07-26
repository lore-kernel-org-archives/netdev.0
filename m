From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 30/36] net: core: convert class code to use dev_groups
Date: Fri, 26 Jul 2013 15:40:35 -0700 (PDT)
Message-ID: <20130726.154035.1983845199334433148.davem@davemloft.net>
References: <1374703539-9705-1-git-send-email-gregkh@linuxfoundation.org>
	<1374703539-9705-31-git-send-email-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759936Ab3GZWkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 18:40:36 -0400
In-Reply-To: <1374703539-9705-31-git-send-email-gregkh@linuxfoundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 24 Jul 2013 15:05:33 -0700

> The dev_attrs field of struct class is going away soon, dev_groups
> should be used instead.  This converts the networking core class code to
> use the correct field.
> 
> In order to do this in the "cleanest" way, some of the macros had to be
> changed to reflect the driver core format of naming show/store
> functions, which accounts for the majority of the churn in this file.
> 
> Cc: netdev@vger.kernel.org
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
> 
> netdev@ maintainers, feel free to take this through your tree, or ACK it
> and I can take it through mine.

Likewise please take this through your tree Greg, thanks!

Acked-by: David S. Miller <davem@davemloft.net>

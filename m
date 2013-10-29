From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] WD80x3: fix printk() calls to netdev_*() calls
Date: Tue, 29 Oct 2013 00:00:58 -0400 (EDT)
Message-ID: <20131029.000058.328421771419196069.davem@davemloft.net>
References: <1382738165-27852-1-git-send-email-quantumdude836@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: quantumdude836@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab3J2EA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 00:00:59 -0400
In-Reply-To: <1382738165-27852-1-git-send-email-quantumdude836@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Drew McGowen <quantumdude836@gmail.com>
Date: Fri, 25 Oct 2013 21:56:05 +0000

> -	printk("%s: WD80x3 at %#3x, %pM",
> -	       dev->name, ioaddr, dev->dev_addr);
> +	netdev_info(dev, "WD80x3 at %#3x, %pM",
> +		ioaddr, dev->dev_addr);

This is incorrect indentation.

On a multi-line function call, the arguments one the second and subsequent
lines must start at exactly the first column after the openning parenthesis
on the first line.

Everyone who makes this mistake is trying to be lazy and use only TAB
characters to indent their code, don't do this.  You must use the
appropriate number of TAB _and_ SPACE characters necessary to achieve
the correct indentation.

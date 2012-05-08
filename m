From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] netxen: added miniDIMM support in driver.
Date: Tue, 08 May 2012 12:53:11 -0400 (EDT)
Message-ID: <20120508.125311.1669426371305176333.davem@davemloft.net>
References: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
	<1336489288-22347-4-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757256Ab2EHQxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 12:53:14 -0400
In-Reply-To: <1336489288-22347-4-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Tue, 8 May 2012 08:01:27 -0700

> +static struct bin_attribute bin_attr_dimm = {
> +	.attr = {.name = "dimm", .mode = (S_IRUGO | S_IWUSR)},

How about a space next to the braces?

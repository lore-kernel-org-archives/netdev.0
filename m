From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] enic: check return value for stat dump
Date: Wed, 10 Jun 2015 23:43:13 -0700 (PDT)
Message-ID: <20150610.234313.1832698141912758206.davem@davemloft.net>
References: <1434003776-31840-1-git-send-email-_govind@gmx.com>
	<1434003776-31840-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbbFKGnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:43:14 -0400
In-Reply-To: <1434003776-31840-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu, 11 Jun 2015 11:52:55 +0530

> We do not check the return value of enic_dev_stats_dump(). If allocation
> fails, we will hit NULL pointer reference.
> 
> Return only if memory allocation fails. For other failures, we return the
> previously recorded values.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.

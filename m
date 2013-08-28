From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] genl: Hold reference on correct module while
 netlink-dump.
Date: Wed, 28 Aug 2013 17:19:55 -0400 (EDT)
Message-ID: <20130828.171955.206794935410358888.davem@davemloft.net>
References: <1377287104-13297-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, johannes.berg@intel.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785Ab3H1VT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 17:19:57 -0400
In-Reply-To: <1377287104-13297-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri, 23 Aug 2013 12:45:04 -0700

> netlink dump operations take module as parameter to hold
> reference for entire netlink dump duration.
> Currently it holds ref only on genl module which is not correct
> when we use ops registered to genl from another module.
> Following patch adds module pointer to genl_ops so that netlink
> can hold ref count on it.
> 
> CC: Jesse Gross <jesse@nicira.com>
> CC: Johannes Berg <johannes.berg@intel.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied and queued up for -stable, thanks.

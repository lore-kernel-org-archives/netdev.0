From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] genl: Fix genl dumpit() locking.
Date: Wed, 28 Aug 2013 17:19:43 -0400 (EDT)
Message-ID: <20130828.171943.684370088688920403.davem@davemloft.net>
References: <1377287095-13245-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, johannes.berg@intel.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729Ab3H1VTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 17:19:47 -0400
In-Reply-To: <1377287095-13245-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri, 23 Aug 2013 12:44:55 -0700

> In case of genl-family with parallel ops off, dumpif() callback
> is expected to run under genl_lock, But commit def3117493eafd9df
> (genl: Allow concurrent genl callbacks.) changed this behaviour
> where only first dumpit() op was called under genl-lock.
> For subsequent dump, only nlk->cb_lock was taken.
> Following patch fixes it by defining locked dumpit() and done()
> callback which takes care of genl-locking.
> 
> CC: Jesse Gross <jesse@nicira.com>
> CC: Johannes Berg <johannes.berg@intel.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, and queued up for -stable.

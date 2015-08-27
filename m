From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: continue in debug mode, if probe fails
Date: Thu, 27 Aug 2015 11:36:05 -0700 (PDT)
Message-ID: <20150827.113605.58103615206012304.davem@davemloft.net>
References: <1440608435-12039-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbH0SgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 14:36:06 -0400
In-Reply-To: <1440608435-12039-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 26 Aug 2015 22:30:35 +0530

> If adapter is flashed with incorrect firmware, probe can fail.
> If probe fails, continue in debug mode, so one can also use the debug
> interface to update the firmware via ethtool.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

If the init fails, there are all of these software datastructure that
have not been allocated at all which ->open() blindly assumes it can
dereference.

Sorry, you're going to have to do a lot more work than this to allow
this situation to proceed.

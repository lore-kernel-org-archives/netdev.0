From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] purge signal handler infrastructure
Date: Mon, 05 May 2014 17:27:10 -0400 (EDT)
Message-ID: <20140505.172710.1571847590302532388.davem@davemloft.net>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089AbaEEV1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 17:27:13 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 5 May 2014 08:56:08 +0800

> When we delay some actions to be executed in asynchronous contexts,
> these usually add unnecessary code complexities, and make their
> behaviours unpredictable and indeterministic. Moreover, as the signal
> handler infrastructure is first stopped when tipc module is removed,
> this may cause some potential risks for us. For instance, although
> signal handler is already stopped, some tipc components still submit
> signal requests to signal handler infrastructure, which may lead to
> some resources not to be released or freed correctly.
> 
> So the series aims to convert all actions being performed in tasklet
> context asynchronously with interface provided by signal handler
> infrastructure to be executed synchronously, thereby deleting the
> whole infrastructure of signal handler.

Series applied, thanks.

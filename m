From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnel: Provide tunnel metadata API for
 CONFIG_INET=n
Date: Wed, 22 Jul 2015 11:09:43 -0700 (PDT)
Message-ID: <20150722.110943.692744854884325882.davem@davemloft.net>
References: <592e4753a6a5752b12cebab65ad426cce20535ca.1437568711.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswtich.org,
	roopa@cumulusnetworks.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbbGVSJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 14:09:44 -0400
In-Reply-To: <592e4753a6a5752b12cebab65ad426cce20535ca.1437568711.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Jul 2015 14:43:58 +0200

> Account for the configuration FIB_RULES=y && INET=n as FIB_RULES can
> be selected by IPV6 or DECNET without INET.
> 
> Fixes: e7030878fc84 ("fib: Add fib rule match on tunnel id")
> Fixes: 3093fbe7ff4b ("route: Per route IP tunnel metadata via lightweight tunnel")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.

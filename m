From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] ila: Optimization to preserve value of
 early demux
Date: Thu, 03 Dec 2015 14:48:45 -0500 (EST)
Message-ID: <20151203.144845.271629627276792795.davem@davemloft.net>
References: <1449011472-1459652-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbLCTsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:48:46 -0500
In-Reply-To: <1449011472-1459652-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 1 Dec 2015 15:11:07 -0800

> ip6tables -t mangle -A PREROUTING --dst 2001:0:0:33::/64 -j ILAIN

The user should have to do anything like this in order to just get
proper working functionality of ILA.

It should just work transparently.

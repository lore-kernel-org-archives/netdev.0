From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next] netlink: have length check of rtnl msg
 before deref
Date: Tue, 26 Mar 2013 08:59:37 +0000
Message-ID: <20130326085937.GE27194@casper.infradead.org>
References: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
 <1364268993-19947-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50859 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757780Ab3CZI7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 04:59:40 -0400
Content-Disposition: inline
In-Reply-To: <1364268993-19947-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/13 at 11:36am, Hong Zhiguo wrote:
> When the legacy array rtm_min still exists, the length check within
> these functions is covered by rtm_min[RTM_NEWTFILTER],
> rtm_min[RTM_NEWQDISC] and rtm_min[RTM_NEWTCLASS].
> 
> But after Thomas Graf removed rtm_min several days ago, these checks
> are missing. Other doit functions should be OK.
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

Acked-by: Thomas Graf <tgraf@suug.ch>

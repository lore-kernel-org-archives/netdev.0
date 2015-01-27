From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bnx2x: fix napi poll return value for repoll
Date: Tue, 27 Jan 2015 00:29:50 -0800 (PST)
Message-ID: <20150127.002950.1557783614506390313.davem@davemloft.net>
References: <1422182363-10932-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariel.elior@qlogic.com, edumazet@google.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbbA0I3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:29:50 -0500
In-Reply-To: <1422182363-10932-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Sun, 25 Jan 2015 16:09:23 +0530

> With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi
> repoll is done only when work_done == budget. When in busy_poll is we return 0
> in napi_poll. We should return budget.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thank you.

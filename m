From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] enic: fix rx napi poll return value
Date: Sat, 24 Jan 2015 22:39:44 -0800 (PST)
Message-ID: <20150124.223944.1768232298710030865.davem@davemloft.net>
References: <1421759776-376-1-git-send-email-_govind@gmx.com>
	<1421759776-376-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariel.elior@qlogic.com, ssujith@cisco.com,
	benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbbAYGjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 01:39:47 -0500
In-Reply-To: <1421759776-376-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Tue, 20 Jan 2015 18:46:15 +0530

> With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi repoll
> is done only when work_done == budget. When we are in busy_poll we return 0 in
> napi_poll. We should return budget.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.

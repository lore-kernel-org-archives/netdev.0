From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: replace macros net_random and
 net_srandom with direct calls to prandom
Date: Tue, 14 Jan 2014 15:15:41 -0800 (PST)
Message-ID: <20140114.151541.900469582607389867.davem@davemloft.net>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: aruna.hewapathirane@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbaANXPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:15:42 -0500
In-Reply-To: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
Date: Sat, 11 Jan 2014 07:15:59 -0500

> This patch removes the net_random and net_srandom macros and replaces
> them with direct calls to the prandom ones. As new commits only seem to
> use prandom_u32 there is no use to keep them around.
> This change makes it easier to grep for users of prandom_u32.
> 
> Signed-off-by: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.

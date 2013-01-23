From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Tue, 22 Jan 2013 20:55:07 -0500 (EST)
Message-ID: <20130122.205507.339713494072219737.davem@davemloft.net>
References: <1358895398-2088-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab3AWBzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 20:55:08 -0500
In-Reply-To: <1358895398-2088-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 22 Jan 2013 14:56:38 -0800

> Fixed code indentation according to comments from David Miller.
> 
> --8<--------------------------cut here-------------------------->8--

This doesn't do what you think it does.  No automated tool is going
to edit the commit message the way you think this will.

You should instead put your "what is different in this revision"
comments right after the "---" below.

> Due to GSO support, GRE can recieve non linear skb which
> results in panic in case of GRE_CSUM.
> Following patch fixes it by using correct csum API.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
 ^^^

Right after that line.

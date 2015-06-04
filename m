From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tulip: rearrange order of searching for substrings
Date: Wed, 03 Jun 2015 20:21:39 -0700 (PDT)
Message-ID: <20150603.202139.67164973308592314.davem@davemloft.net>
References: <1433331843-32301-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbFDDVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:21:40 -0400
In-Reply-To: <1433331843-32301-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Wed,  3 Jun 2015 13:44:03 +0200

> Currently, two of the branches are dead code, since an earlier smaller
> substring would have been found ("TP" in the "TP_NW" case and either
> of "BNC" and "AUI" in the "BNC_AUI" case). Rearrange the strstr()
> calls so that the longer strings are searched for first.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied to net-next, thank you.

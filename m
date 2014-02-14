From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] dccp: re-enable debug macro
Date: Fri, 14 Feb 2014 00:35:06 -0500 (EST)
Message-ID: <20140214.003506.1226905800810452794.davem@davemloft.net>
References: <20140213190233.0f0889a4@liptov.cs.ualberta.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbaBNFfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 00:35:08 -0500
In-Reply-To: <20140213190233.0f0889a4@liptov.cs.ualberta.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 13 Feb 2014 19:02:33 -0700

> dccp tfrc: revert
> 
> This reverts 6aee49c558de (Jan 4, 2014) since the variable tfrc_debug is
> referenced by the tfrc_pr_debug(fmt, ...) macro when TFRC debugging is
> enabled. If it is enabled, use of the macro produces a compilation error.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks Gerrit.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Set cmd field in
 ETHTOOL_GLINKSETTINGS response to wrong nwords
Date: Wed, 16 Mar 2016 19:26:38 -0400 (EDT)
Message-ID: <20160316.192638.370528273688631022.davem@davemloft.net>
References: <20160314010537.GD21187@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934717AbcCPX0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 19:26:40 -0400
In-Reply-To: <20160314010537.GD21187@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 14 Mar 2016 01:05:38 +0000

> When the ETHTOOL_GLINKSETTINGS implementation finds that userland is
> using the wrong number of words of link mode bitmaps (or is trying to
> find out the right numbers) it sets the cmd field to 0 in the response
> structure.
> 
> This is inconsistent with the implementation of every other ethtool
> command, so let's remove that inconsistency before it gets into a
> stable release.
> 
> Fixes: 3f1ac7a700d03 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS API")
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied and queued up for -stable, thanks Ben.

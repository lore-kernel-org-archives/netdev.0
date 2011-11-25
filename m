From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Revert ARCNET and PHYLIB to tristate options
Date: Fri, 25 Nov 2011 13:22:20 -0500 (EST)
Message-ID: <20111125.132220.150546128040363058.davem@davemloft.net>
References: <1322119410.2839.262.camel@deadeye>
	<20111125.013102.841551383223873520.davem@davemloft.net>
	<1322230071.2839.337.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	debian-kernel@lists.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab1KYSXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 13:23:33 -0500
In-Reply-To: <1322230071.2839.337.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 25 Nov 2011 14:07:51 +0000

> Well, I can't think why it would be built in, since PHY modules can be
> auto-loaded now.

It's because drivers select the thing.

Try allmodconfig for yourself.

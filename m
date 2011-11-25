From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Revert ARCNET and PHYLIB to tristate options
Date: Fri, 25 Nov 2011 01:31:02 -0500 (EST)
Message-ID: <20111125.013102.841551383223873520.davem@davemloft.net>
References: <1322119410.2839.262.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	debian-kernel@lists.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab1KYGc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 01:32:26 -0500
In-Reply-To: <1322119410.2839.262.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 24 Nov 2011 07:23:30 +0000

> Commit 88491d8103498a6166f70d5999902fec70924314 ("drivers/net: Kconfig
> & Makefile cleanup") changed the type of these options to bool, but
> they select code that could (and still can) be built as modules.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> I consider the inability to build arcnet.o and libphy.o as modules to be
> a regression in 3.2 for general-purpose distribution kernels.
> Therefore, please apply this to the net tree.

I challenge you to get PHYLIB set to 'm' in a configuration such as
"allmodconfig" which is clearly in line with the kind of configuration
which "distribution kernels" use.

Did you really even try to see if it mattered?  Or did you just test
your change with a stripped down configuration you happened to have
readily available in some build tree?

I really consider this change entirely pointless, because for the
situation where you say it matters, it actually doesn't as far as I
can tell.

I'm therefore rejecting this patch.

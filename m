From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 7/8] net: Revert ARCNET and PHYLIB to tristate
 options
Date: Sat, 26 Nov 2011 14:42:08 -0500 (EST)
Message-ID: <20111126.144208.824312454374500957.davem@davemloft.net>
References: <1322267572.2839.381.camel@deadeye>
	<1322268002.2839.390.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042Ab1KZTmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 14:42:16 -0500
In-Reply-To: <1322268002.2839.390.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 26 Nov 2011 00:40:02 +0000

> commit 88491d8103498a6166f70d5999902fec70924314 ("drivers/net: Kconfig
> & Makefile cleanup") changed the type of these options to bool, but
> they select code that could (and still can) be built as modules.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> Yes David, they do still build this way.  Even in an allmodconfig
> configuration, now.  And I still really want this in net.

Color me extremely impressed.

Ok, I'll put this into 'net', pull it into 'net-next', then apply the
rest of this series there.

Thanks!

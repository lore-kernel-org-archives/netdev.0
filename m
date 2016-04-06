From: David Miller <davem@davemloft.net>
Subject: Re: af_packet: tone down the Tx-ring unsupported spew.
Date: Wed, 06 Apr 2016 16:05:42 -0400 (EDT)
Message-ID: <20160406.160542.578786172468372244.davem@davemloft.net>
References: <20160404191150.GA7224@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbcDFUFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:05:44 -0400
In-Reply-To: <20160404191150.GA7224@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Mon, 4 Apr 2016 15:11:50 -0400

> Trinity and other fuzzers can hit this WARN on far too easily,
> resulting in a tainted kernel that hinders automated fuzzing.
> 
> Replace it with a rate-limited printk.
> 
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

Looks good, thanks Dave.

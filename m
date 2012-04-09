From: David Miller <davem@davemloft.net>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big
 network copies (page allocation failure)
Date: Mon, 09 Apr 2012 14:12:41 -0400 (EDT)
Message-ID: <20120409.141241.1216091936509309354.davem@davemloft.net>
References: <20120329163800.GH24933@merlins.org>
	<1333044575.2656.1.camel@bwh-desktop.uk.solarflarecom.com>
	<20120409172051.GR32290@merlins.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: marc@merlins.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab2DISM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 14:12:56 -0400
In-Reply-To: <20120409172051.GR32290@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc MERLIN <marc@merlins.org>
Date: Mon, 9 Apr 2012 10:20:51 -0700

> Any idea what's going on, what bucket of RAM is an issue for the driver
> (total RAM is more than plenty), and where I should go from there?

The wireless layer is allocating high-order pages, so it's
not the amount of ram, it's the fragmentation of it leading
to a lack of those high-order pages.

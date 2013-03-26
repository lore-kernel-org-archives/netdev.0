From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/12] 6lowpan: Some more bug fixes
Date: Tue, 26 Mar 2013 12:39:17 -0400 (EDT)
Message-ID: <20130326.123917.76576913792839595.davem@davemloft.net>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alan@signal11.us,
	alex.bluesman.smirnov@gmail.com, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: tony.cheneau@amnesiak.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965531Ab3CZQjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:39:19 -0400
In-Reply-To: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Cheneau <tony.cheneau@amnesiak.org>
Date: Mon, 25 Mar 2013 23:59:20 -0400

> This patchset fixes serious bugs within the 6LoWPAN modules. I wrote a script
> (available at [1]) to prove the issues are real.  One can try and see that
> without these patches, most of the test fail (e.g. packet dropped by the
> receiver or node crashing). With all patches applied, all tests succeed. The
> tests themselves are very basic: sending ICMP packets, sending UDP packets,
> sending TCP packets, varying size of the packets. This actually triggers some
> 6LoWPAN specific code, namely fragmentation, packet reassembly and header
> compression.
> 
> This code passed the checkpatch.pl tool with a few warnings, that I believe
> are OK. It should apply cleanly on the latest net-next.

Series applied, thanks.

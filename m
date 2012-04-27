From: David Miller <davem@davemloft.net>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Fri, 27 Apr 2012 16:48:57 -0400 (EDT)
Message-ID: <20120427.164857.709676397431213834.davem@davemloft.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120427134127.6d536a96@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: darkbasic@linuxsystems.it, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227Ab2D0UuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 16:50:09 -0400
In-Reply-To: <20120427134127.6d536a96@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 27 Apr 2012 13:41:27 -0700

> Mirko and I were working on a related issue, here is his fix.
> I proposed a similar alternative, but he was unavailable to test it,
> and therefore was still pending.  Does this fix your problem?

Nothing sets ->rx_vlan in that patch.

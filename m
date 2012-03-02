From: David Miller <davem@davemloft.net>
Subject: Re: TCP_STREAM performance regression on commit b3613118
Date: Thu, 01 Mar 2012 22:07:43 -0500 (EST)
Message-ID: <20120301.220743.2174015405223036036.davem@davemloft.net>
References: <1329472239.2861.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120217.133327.1178765872497293871.davem@davemloft.net>
	<1330656317.21053.1411.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: feng.tang@intel.com, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, tim.c.chen@intel.com,
	ying.huang@intel.com, netdev@vger.kernel.org
To: alex.shi@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756843Ab2CBDHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 22:07:47 -0500
In-Reply-To: <1330656317.21053.1411.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Shi <alex.shi@intel.com>
Date: Fri, 02 Mar 2012 10:45:17 +0800

> Add CC to tang feng, He is working on this issue. 

Is he?  I'm pretty sure this is due to the TCP receive window growing
issue Eric Dumazet, Neal Cardwell and I are discussing in the thread
starting at:

http://marc.info/?l=linux-netdev&m=132916352815286&w=2

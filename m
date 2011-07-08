From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] sky2: force receive checksum when using
 RSS on some hardware (v2)
Date: Fri, 08 Jul 2011 08:54:25 -0700 (PDT)
Message-ID: <20110708.085425.2223360541061693097.davem@davemloft.net>
References: <CAHXqBF+Ha9XaMDB0x1XBD633mj2b6Jxmg9U_JSokrov90gPA-g@mail.gmail.com>
	<20110707101322.784409eb@nehalam.ftrdhcpuser.net>
	<20110707164000.6f3f58f4@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908Ab1GHPy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 11:54:28 -0400
In-Reply-To: <20110707164000.6f3f58f4@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 7 Jul 2011 16:40:00 -0700

> Found when reviewing the vendor driver. Apparently some chip versions
> require receive checksumming to be enabled in order for RSS to work.
> 
> Also, if fix_features has to change some settings; put in message
> in log in similar manner to netdev_fix_features.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> v2 - enforce the requirement in fix_features rather than set features

All 5 patches applied, I changed this patch #1 to use netdev_info()
as per the discussion.

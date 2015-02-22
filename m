From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] reject creation of netdev names with colons
Date: Sat, 21 Feb 2015 21:46:02 -0500 (EST)
Message-ID: <20150221.214602.384556263249269746.davem@davemloft.net>
References: <1424219517-9386-1-git-send-email-mthode@mthode.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mthode@mthode.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbbBVCqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 21:46:07 -0500
In-Reply-To: <1424219517-9386-1-git-send-email-mthode@mthode.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Thode <mthode@mthode.org>
Date: Tue, 17 Feb 2015 18:31:57 -0600

> colons are used as a separator in netdev device lookup in dev_ioctl.c
> 
> Specific functions are SIOCGIFTXQLEN SIOCETHTOOL SIOCSIFNAME
> 
> Signed-off-by: Matthew Thode <mthode@mthode.org>

Applied thanks.

Please put a proper subsystem prefix in your Subject line
for future patches.  In this case an appropriate prefix
would have been "net: reject..."

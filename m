From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: Properly validate RTA_VIA payload length
Date: Fri, 06 Mar 2015 15:19:19 -0500 (EST)
Message-ID: <20150306.151919.1394197533340244306.davem@davemloft.net>
References: <1425638820-19990-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301AbbCFUTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:19:21 -0500
In-Reply-To: <1425638820-19990-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Fri, 6 Mar 2015 10:47:00 +0000

> If the nla length is less than 2 then the nla data could be accessed
> beyond the accessible bounds. So ensure that the nla is big enough to
> at least read the via_family before doing so. Replace magic value of
> 2.
> 
> Fixes: 03c0566542f4 ("mpls: Basic support for adding and removing routes")
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied, thank you.

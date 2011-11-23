From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4 : igmp : optimize timer modify logic in
 igmp_mod_timer()
Date: Wed, 23 Nov 2011 17:28:14 -0500 (EST)
Message-ID: <20111123.172814.1626722266908002386.davem@davemloft.net>
References: <1322066322-4782-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104Ab1KWW2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 17:28:17 -0500
In-Reply-To: <1322066322-4782-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Thu, 24 Nov 2011 00:38:42 +0800

> When timer is pending and expires less-than-or-equal-to new delay,
> we need not used del_timer()/add_timer().
> 
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>

You did not answer Eric's question, why are you optimizing this
less-used code path?

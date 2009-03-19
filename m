From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Fix incorrect disable_ipv6 behavior
Date: Wed, 18 Mar 2009 18:23:06 -0700 (PDT)
Message-ID: <20090318.182306.85470030.davem@davemloft.net>
References: <1236292120-32050-1-git-send-email-brian.haley@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50093
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752496AbZCSBXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:23:19 -0400
In-Reply-To: <1236292120-32050-1-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Thu,  5 Mar 2009 17:28:40 -0500

> Fix the behavior of allowing both sysctl and addrconf_dad_failure()
> to set the disable_ipv6 parameter without any bad side-effects.
> If DAD fails and accept_dad > 1, we will still set disable_ipv6=1,
> but then instead of allowing an RA to add an address then
> immediately fail DAD, we simply don't allow the address to be
> added in the first place.  This also lets the user set this flag
> and disable all IPv6 addresses on the interface, or on the entire
> system.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied to net-next-2.6, thanks!

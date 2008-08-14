From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netns: Add network namespace argument to
 rt6_fill_node() and ipv6_dev_get_saddr()
Date: Thu, 14 Aug 2008 15:33:40 -0700 (PDT)
Message-ID: <20080814.153340.241442105.davem@davemloft.net>
References: <48A4A5C4.4080109@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, containers@lists.osdl.org,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbYHNWdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:33:38 -0400
In-Reply-To: <48A4A5C4.4080109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 14 Aug 2008 17:38:12 -0400

> ipv6_dev_get_saddr() blindly de-references dst_dev to get the network
> namespace, but some callers might pass NULL.  Change callers to pass a
> namespace pointer instead.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

This looks tons better than your first attempt :-)

Applied, thanks Brian.

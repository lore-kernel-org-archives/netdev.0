From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] NET: Multiple queue network device support REPOST
Date: Thu, 08 Mar 2007 22:21:54 -0800 (PST)
Message-ID: <20070308.222154.74746753.davem@davemloft.net>
References: <1173420779298-git-send-email-peter.p.waskiewicz.jr@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38205
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992993AbXCIGV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 01:21:58 -0500
In-Reply-To: <1173420779298-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


You didn't address my correction the other day wherein I clarified
for you that my idea was not to store the queue mapping in
skb->priority but rather to shrink skb->priority to a u16 and
add a new u16 skb->queue_mapping or whatever field to store the
necessary information.

You're just posting a set of patches using the same approach again
plus some bug fixes, so there is essentially nothing new for anyone to
review.

Why ask for feedback if you fail to take any of it into consideration?
:-/

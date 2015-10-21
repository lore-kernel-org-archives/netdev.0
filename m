From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Wed, 21 Oct 2015 07:43:32 -0700 (PDT)
Message-ID: <20151021.074332.1709904332480699231.davem@davemloft.net>
References: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbbJUO1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:27:08 -0400
In-Reply-To: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 16 Oct 2015 13:07:59 +0200

> This of course does not fix the reuse problem for the applications;
> it just makes it less likely to be hit in common usage patterns.

Not only does this not fix the problem, it makes the incentive to fix
that problem much smaller.

Therefore I am not applying this patch, sorry.

Fix the real problem, then come talk to us.

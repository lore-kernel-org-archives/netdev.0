From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Wed, 21 Oct 2015 08:32:14 -0700 (PDT)
Message-ID: <20151021.083214.534622235927401863.davem@davemloft.net>
References: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
	<20151021.074332.1709904332480699231.davem@davemloft.net>
	<20151021164613.24650836@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755677AbbJUPPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:15:48 -0400
In-Reply-To: <20151021164613.24650836@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 21 Oct 2015 16:46:13 +0200

> For example, we could always alloc a new ifindex when moving interfaces
> between name spaces. That would be probably the tiniest race window we
> could get to (still not zero!) but I guess it would break apps that
> assume that ifindex doesn't change when moving interfaces between name
> spaces (which is not true, such apps are already broken, they just
> happen to work in 99% of cases). The second best solution that doesn't
> break those apps at the cost of leaving the race window wider, is this
> patch.

As you say the apps are broken, so file a bug and have them fixed.

The assumption is clearly invalid, so apps cannot make such an
assumption.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Mon, 25 Apr 2016 16:42:27 -0400 (EDT)
Message-ID: <20160425.164227.1599148827995063295.davem@davemloft.net>
References: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com>
	<20160425.152611.583503438886577374.davem@davemloft.net>
	<571E72AA.4030100@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mmanning@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933455AbcDYUma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:42:30 -0400
In-Reply-To: <571E72AA.4030100@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 25 Apr 2016 13:40:26 -0600

> It's unfortunate you want to take that action. Last week I came across
> a prior attempt by Stephen to do this same thing -- keep IPv6
> addresses. That prior attempt was reverted by commit
> 73a8bd74e261. Cumulus, Brocade, and others clearly want this
> capability.

But nobody has implemented it correctly, it doesn't matter who wants
the feature.  That's why it keeps getting reverted.

Also, this testing you are talking about should have happened long
before you submitted that first patch that introduced all of these
regressions.  My observations tell me that the bulk of the testing
happened afterwards and that's why all the regressions are popping up
now.

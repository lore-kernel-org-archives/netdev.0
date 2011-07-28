From: David Miller <davem@davemloft.net>
Subject: Re: invalid requirement from ethtool?
Date: Wed, 27 Jul 2011 22:43:09 -0700 (PDT)
Message-ID: <20110727.224309.779719590419361909.davem@davemloft.net>
References: <20110726124222.GA4842@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753576Ab1G1FnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:43:13 -0400
In-Reply-To: <20110726124222.GA4842@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Tue, 26 Jul 2011 15:42:22 +0300

> I think both params zero should be allowed and mean coalescing is not
> operational, thus we can remove these comments from ethtool.h

The existing precendence has existed for more than 10 years.  You can't
just change it like this.

You'll need to find a new way to encode "disabled" coalescing.

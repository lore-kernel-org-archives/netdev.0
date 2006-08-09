From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 17:22:41 -0700 (PDT)
Message-ID: <20060808.172241.51700454.davem@davemloft.net>
References: <200608090123.01123.ak@suse.de>
	<20060808.171152.58440635.davem@davemloft.net>
	<Pine.LNX.4.61.0608081707410.2452@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56971
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030368AbWHIAWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:22:37 -0400
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0608081707410.2452@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akepner@sgi.com
Date: Tue, 8 Aug 2006 17:11:29 -0700 (PDT)

> But there's alot of state to update (more or less
> atomically, too) in the TCP hashes. Looks tricky to
> do that without hurting performance, especially since
> you'll probably want to resize the tables when you've
> discovered they're full and busy....

There have been two failed attempts at this :)

For the time being I think the routing cache can be
dynamically sized with less effort, and I might take
a stab at that today.

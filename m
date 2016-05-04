From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vlan: Propagate MAC address to VLANs unless
 explicitly set
Date: Wed, 04 May 2016 11:58:15 -0400 (EDT)
Message-ID: <20160504.115815.1348535190105538815.davem@davemloft.net>
References: <5728BA0B.6050807@brocade.com>
	<5728C1AC.3090708@brocade.com>
	<20160504092801.GC19967@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mmanning@brocade.com, netdev@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbcEDP6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 11:58:19 -0400
In-Reply-To: <20160504092801.GC19967@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Wed, 4 May 2016 11:28:02 +0200

> The commit message says "unless explicitly changed for the VLAN" but
> what you really check is "if it is the same as real device MAC address".
> This, in general, is not the same. (I believe this is what David tries
> to explain from the start.)

Even more proof that these MAC checks are rediculous, confusing, and
that we need to use a boolean state stores in the vlan private in
order to implement the intended semantics properly and more importantly
"clearly".

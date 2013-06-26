From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] tcp: introduce TCP experimental option for SMC-R
Date: Wed, 26 Jun 2013 15:22:28 -0700 (PDT)
Message-ID: <20130626.152228.1637104209838437474.davem@davemloft.net>
References: <20130625135904.840700403@linux.vnet.ibm.com>
	<20130625140033.744208982@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206Ab3FZWW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:22:29 -0400
In-Reply-To: <20130625140033.744208982@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We've already been bitten by having things like the VXLAN port number
change on us after we've deployed the feature already.  So this must
be finalized in a real RFC before I am willing to consider this patch.

Also, I and everyone else, wants to see the user of these new flags
and behavior.  That means you must post the entire SMC-R protocol stack
implementation at the time that you want this set of changes integrated.

I'm not applying this patch until both of those issues are fully resolved.

Thanks.

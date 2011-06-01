From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure
 counters
Date: Wed, 01 Jun 2011 12:03:00 -0700 (PDT)
Message-ID: <20110601.120300.130602301077156524.davem@davemloft.net>
References: <4DE63E85.7020508@redhat.com>
	<20110601135321.GA2909@psychotron.brq.redhat.com>
	<16056.1306944819@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, fbl@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759223Ab1FATDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 15:03:13 -0400
In-Reply-To: <16056.1306944819@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 01 Jun 2011 09:13:39 -0700

> 	The "this dingus was added in version X.Y.Z" is there because
> users sometimes read the most recent version of the documentation (that
> they get from the internet) and then would become confused when their
> older distro driver lacked some option described in the documentation.

I disagree with this whole concept, because distros backport features
like this into their kernel and therefore the feature is showing up in
version X.Y.$(Z-20).

And distro kernels are what %99.9999 of users are exposed to.

Therefore, I think this version specification is not only pointless
but even a possible cause of confusion.


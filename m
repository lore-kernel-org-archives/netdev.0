From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Tue, 30 Jun 2009 20:16:30 -0700 (PDT)
Message-ID: <20090630.201630.134200035.davem@davemloft.net>
References: <1246379267.3749.42.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: markmc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752455AbZGADQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 23:16:24 -0400
In-Reply-To: <1246379267.3749.42.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>
Date: Tue, 30 Jun 2009 17:27:47 +0100

> For these reasons, it makes sense to allow distributions to disable
> netfilter on the bridge by default and require those specialized users
> to enable it explicitly via sysctl.

I heard that distributions ship some file, what's it called...
something like /etc/sysctl.conf :-)

Really, if someone thinkgs the default stinks and dists don't like it
for their users, they can use sysctl.conf to set it how they please.

Notwithstanding that changing this default can break working
setups and scripts.  Yes they can "change", but they were just
(rightly) using the kernel as it came to them.

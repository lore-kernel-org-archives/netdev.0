From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/23] [PATCH] [XFRM] POLICY: sub policy support.
Date: Wed, 02 Aug 2006 15:09:03 -0700 (PDT)
Message-ID: <20060802.150903.71091149.davem@davemloft.net>
References: <1154165451738-git-send-email-nakam@linux-ipv6.org>
	<Pine.LNX.4.64.0608021152060.21751@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27077
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932265AbWHBWJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 18:09:05 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0608021152060.21751@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Wed, 2 Aug 2006 12:04:31 -0400 (EDT)

> Why can't IPSec & MIP transforms be bundled on the same policy?

At the first year of netconf, Yoshifuji went into detail
as to why the IPSEC and MIP transformations had to live
seperately.

It's partly a side effect of different userland daemons controlling
IPSEC vs. MIP configuration.

> Or, perhaps a different approach is needed, where the disposition of a 
> policy can be to re-submit a packet for another policy match after the 
> current bundle has been traversed (something like NF_REPEAT).

We can consider an approach like this as a future refinement.
It would allow arbitrary nesting of sub-transforms, for sure,
just like netfilter's NF_REPEAT.


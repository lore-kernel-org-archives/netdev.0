From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's
 ndisc_recv_ns.
Date: Sun, 23 Mar 2008 21:49:42 -0700 (PDT)
Message-ID: <20080323.214942.188347230.davem@davemloft.net>
References: <47CFD2ED.3060207@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751507AbYCXEtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 00:49:43 -0400
In-Reply-To: <47CFD2ED.3060207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 06 Mar 2008 14:18:05 +0300

> +struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
> +		struct net *net, const void *pkey, struct net_device *dev)
> +{

You don't export this to modules, so when IPV6 is modular
the build fails.

Please fix this up and resubmit, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 37/40] rtnetlink: Compute and store minimum ifinfo
 dump size
Date: Wed, 08 Jun 2011 00:12:14 -0700 (PDT)
Message-ID: <20110608.001214.1214949405952155837.davem@davemloft.net>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1307449995-9458-38-git-send-email-jeffrey.t.kirsher@intel.com>
	<1307513397.3961.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, gregory.v.rose@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab1FHHN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 03:13:26 -0400
In-Reply-To: <1307513397.3961.0.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 08 Jun 2011 08:09:57 +0200

> Curious. Weren't dumps supposed to be split up into small chunks and
> then delivered? Where is this splitting going wrong, and could it be
> improved to split into smaller pieces?

You can only split at the individual object boundary.

And in these cases individual single network device instances are too
large to go in one SKB.

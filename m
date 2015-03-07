From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Sat, 07 Mar 2015 01:12:49 -0500 (EST)
Message-ID: <20150307.011249.990503044534249616.davem@davemloft.net>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
	<20150306.002410.1359006818497057668.davem@davemloft.net>
	<20150307031013.GC502@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbbCGGMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 01:12:54 -0500
In-Reply-To: <20150307031013.GC502@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Fri, 6 Mar 2015 22:10:13 -0500

> but this was not possible for SNMP-based tools that are not aware of
> the aggregation of ports on the host.

The suggested value to report HAS NO MEANING.

If you just add the speeds up that's complete bullshit.

Nothing prevents the SNMP userland from doing the right thing
and figuring out the geography and perhaps even exporting
that geography to SNMP querying agents.

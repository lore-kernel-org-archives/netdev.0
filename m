From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv2 bridge 7/7] bridge: Add the ability to show dump
 the vlan map from a bridge port
Date: Sat, 22 Sep 2012 13:27:47 -0400 (EDT)
Message-ID: <20120922.132747.1937291269030903700.davem@davemloft.net>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
	<1348058536-22607-8-git-send-email-vyasevic@redhat.com>
	<1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596Ab2IVR1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:27:49 -0400
In-Reply-To: <1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 22 Sep 2012 18:15:32 +0100

> On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
>> Using the RTM_GETLINK dump the vlan map of a given bridge port.
> [...]
> 
> This enlarges the RTM_GETLINK response quite a bit.  I think perhaps
> this should be optional, like IFLA_VFINFO_LIST is now.

Completely agreed.

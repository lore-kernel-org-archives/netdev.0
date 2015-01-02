From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Consistently include VLAN header in
 flow and port stats.
Date: Fri, 02 Jan 2015 16:14:32 -0500 (EST)
Message-ID: <20150102.161432.12979147584792533.davem@davemloft.net>
References: <1420044346-27957-1-git-send-email-blp@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com,
	mshindo@vmware.com
To: blp@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbABVOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:14:35 -0500
In-Reply-To: <1420044346-27957-1-git-send-email-blp@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@nicira.com>
Date: Wed, 31 Dec 2014 08:45:46 -0800

> Until now, when VLAN acceleration was in use, the bytes of the VLAN header
> were not included in port or flow byte counters.  They were however
> included when VLAN acceleration was not used.  This commit corrects the
> inconsistency, by always including the VLAN header in byte counters.
> 
> Previous discussion at
> http://openvswitch.org/pipermail/dev/2014-December/049521.html
> 
> Reported-by: Motonori Shindo <mshindo@vmware.com>
> Signed-off-by: Ben Pfaff <blp@nicira.com>

Applied, thank you.

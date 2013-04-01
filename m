From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: make flags symmetrical
Date: Mon, 01 Apr 2013 17:18:58 -0400 (EDT)
Message-ID: <20130401.171858.2177408540657698898.davem@davemloft.net>
References: <20130401115315.1f8e4213@nehalam.linuxnetplumber.net>
	<5159EB2B.7070504@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758537Ab3DAVTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 17:19:02 -0400
In-Reply-To: <5159EB2B.7070504@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 01 Apr 2013 13:16:43 -0700

> I am depending on this feature.  There is no other way I know
> of to determine if an interface is actually currently acting
> PROMISC or not.

Netlink interface dump, SIOGIFCONF, etc. should provide this
information in one form or another.

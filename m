From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: netlink: filter particular protocols from
 analyzers
Date: Thu, 05 Sep 2013 15:54:17 -0400 (EDT)
Message-ID: <20130905.155417.2121308426258876038.davem@davemloft.net>
References: <1378396127-8342-1-git-send-email-dborkman@redhat.com>
	<20130905.144442.2085221662776542385.davem@davemloft.net>
	<5228DFF0.7070106@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809Ab3IETyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:54:19 -0400
In-Reply-To: <5228DFF0.7070106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 05 Sep 2013 21:48:00 +0200

> With socket(PF_PACKET, ..., htons(ETH_P_ALL)) you will already get
> all users from the suggested white-list of the patch, which is the
> majority of netlink users I believe. Hence, you do not need to have
> one socket per protocol. skbs from there should get dragged into
> pf_packet via dev_queue_xmit_nit() which works on ptype_all list.

What about user level netlink protocols?

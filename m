From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/8] More genericization of struct rtable
Date: Wed, 04 May 2011 10:14:38 -0700 (PDT)
Message-ID: <20110504.101438.193716658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751916Ab1EDRPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 82C5024C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:14:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set does more work to minimize or completely eliminate
various fields of struct rtable, with the goal of making the
structure as generic and non-specific as possible.

First we reduce rt->rt_tos such that it is only used as a key
for routing cache lookups, and rename it rt->rt_key_tos to
reflect this fact.

Next some output route lookup interface tweaks leading to the
removal of several rt->rt_{dst,src} accesses, replacing those
with flowi4->{daddr,saddr}

More to come.

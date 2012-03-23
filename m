From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net: hardware limited MTU for 802.1Q frames
Date: Fri, 23 Mar 2012 14:34:31 -0400 (EDT)
Message-ID: <20120323.143431.1155326472280529505.davem@davemloft.net>
References: <1332499886-1126-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msink@permonline.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303Ab2CWSe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 14:34:56 -0400
In-Reply-To: <1332499886-1126-1-git-send-email-msink@permonline.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Sinkovsky <msink@permonline.ru>
Date: Fri, 23 Mar 2012 15:51:26 +0500

> Some chips (WIZnet as example) have hardware limited MTU -

And such devices should se NETIF_F_VLAN_CHALLENGED because they
simply cannot support VLAN's properly.

Trying to support these kind of situations is simply not worth the
effort, people who want to use VLANs will simply purchase suitably
capable hardware.

I refuse to even entertain this kind of change, sorry.

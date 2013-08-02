From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/3] af_packet: simplify VLAN frame check in
 packet_snd
Date: Fri, 02 Aug 2013 14:59:03 -0700 (PDT)
Message-ID: <20130802.145903.369662363069433078.davem@davemloft.net>
References: <1375436261-6746-1-git-send-email-phil@nwl.cc>
	<1375436261-6746-2-git-send-email-phil@nwl.cc>
	<1375436261-6746-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab3HBV7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 17:59:04 -0400
In-Reply-To: <1375436261-6746-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Fri,  2 Aug 2013 11:37:41 +0200

> For ethernet frames, eth_type_trans() already parses the header, so one
> can skip this when checking the frame size.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.

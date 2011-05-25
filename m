From: David Miller <davem@davemloft.net>
Subject: Re: VLAN test cases in 2.6.38.7
Date: Tue, 24 May 2011 22:47:20 -0400 (EDT)
Message-ID: <20110524.224720.67532722991776785.davem@davemloft.net>
References: <4DDBFDD6.4060903@candelatech.com>
	<4DDC0236.4090800@candelatech.com>
	<4DDC36C4.80408@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab1EYCr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 22:47:26 -0400
In-Reply-To: <4DDC36C4.80408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 24 May 2011 15:52:52 -0700

> Either my ubridge code is broken, or 2.6.38.7+ doesn't send
> tp_vlan_tci
> properly.  All I ever see is zero for that field.

You need to put the af_packet socket into TPACKET_V2 format.

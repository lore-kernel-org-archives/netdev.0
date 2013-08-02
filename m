From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] af_packet: fix for sending VLAN frames via
 packet_mmap
Date: Fri, 02 Aug 2013 14:58:57 -0700 (PDT)
Message-ID: <20130802.145857.61122061546813600.davem@davemloft.net>
References: <20130801.181208.804928209108880255.davem@davemloft.net>
	<1375436261-6746-1-git-send-email-phil@nwl.cc>
	<1375436261-6746-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab3HBV66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 17:58:58 -0400
In-Reply-To: <1375436261-6746-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Fri,  2 Aug 2013 11:37:40 +0200

> Since tpacket_fill_skb() parses the protocol field in ethernet frames'
> headers, it's easy to see if any passed frame is a VLAN one and account
> for the extended size.
> 
> But as the real protocol does not turn up before tpacket_fill_skb()
> runs which in turn also checks the frame length, move the max frame
> length calculation into the function.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.

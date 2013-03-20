From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Wed, 20 Mar 2013 12:33:44 -0400 (EDT)
Message-ID: <20130320.123344.1566685302188091721.davem@davemloft.net>
References: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com>
	<1363761764-4374-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758227Ab3CTQdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:33:46 -0400
In-Reply-To: <1363761764-4374-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 20 Mar 2013 02:42:44 -0400

> Fix flaky results with PACKET_FANOUT_HASH depending on whether the
> two flows hash into the same packet socket or not.
> 
> Also adds tests for PACKET_FANOUT_LB and PACKET_FANOUT_CPU and
> replaces the counting method with a packet ring.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.  I'll retest on my sparc64 box later today.

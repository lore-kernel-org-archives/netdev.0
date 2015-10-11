From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4 v2] net: VRF support in IPv6 stack
Date: Sun, 11 Oct 2015 04:48:52 -0700 (PDT)
Message-ID: <20151011.044852.1852869402648088161.davem@davemloft.net>
References: <1444255337-36414-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbbJKLc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 07:32:58 -0400
In-Reply-To: <1444255337-36414-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please minimize the crazy pointer casting in this series.

All of these casts between ipv4/ipv6 route objects and dsts are
completely unnecessary.

Prefer to maintain an rt/rt6 in local variables, and then when you
need the dst say &rt6->dst, or to get the device say rt6->dst.dev or
similar.

Thanks.

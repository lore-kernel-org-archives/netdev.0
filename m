From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tcp: properly update lost_cnt_hint during shifting
Date: Sun, 02 Oct 2011 20:33:46 -0400 (EDT)
Message-ID: <20111002.203346.1030463582070299609.davem@davemloft.net>
References: <4E88737E.5030906@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab1JCAeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 20:34:00 -0400
In-Reply-To: <4E88737E.5030906@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Sun, 02 Oct 2011 22:21:50 +0800

> lost_skb_hint is used by tcp_mark_head_lost() to mark the first unhandled skb.
> lost_cnt_hint is the number of packets or sacked packets before the lost_skb_hint;
> When shifting a skb that is before the lost_skb_hint, if tcp_is_fack() is ture,
> the skb has already been counted in the lost_cnt_hint; if tcp_is_fack() is false,
> tcp_sacktag_one() will increase the lost_cnt_hint. So tcp_shifted_skb() does not
> need to adjust the lost_cnt_hint by itself. When shifting a skb that is equal to
> lost_skb_hint, the shifted packets will not be counted by tcp_mark_head_lost().
> So tcp_shifted_skb() should adjust the lost_cnt_hint even tcp_is_fack(tp) is true.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

Applied, thanks.

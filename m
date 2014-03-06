From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 1/2] l2tp: fix manual sequencing (de)activation
 in L2TPv2
Date: Thu, 06 Mar 2014 14:26:02 -0500 (EST)
Message-ID: <20140306.142602.1265342336657169924.davem@davemloft.net>
References: <cover.1393966618.git.g.nault@alphalink.fr>
	<4a93fa220e4041046b490ba5957b60a244ebcb44.1394100210.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaCFT0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:26:05 -0500
In-Reply-To: <4a93fa220e4041046b490ba5957b60a244ebcb44.1394100210.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 6 Mar 2014 11:14:30 +0100

> Commit e0d4435f "l2tp: Update PPP-over-L2TP driver to work over L2TPv3"
> broke the PPPOL2TP_SO_SENDSEQ setsockopt. The L2TP header length was
> previously computed by pppol2tp_l2t_header_len() before each call to
> l2tp_xmit_skb(). Now that header length is retrieved from the hdr_len
> session field, this field must be updated every time the L2TP header
> format is modified, or l2tp_xmit_skb() won't push the right amount of
> data for the L2TP header.
> 
> This patch uses l2tp_session_set_header_len() to adjust hdr_len every
> time sequencing is (de)activated from userspace (either by the
> PPPOL2TP_SO_SENDSEQ setsockopt or the L2TP_ATTR_SEND_SEQ netlink
> attribute).
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied.

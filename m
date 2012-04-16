From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: restore formatting of macros for tcp_skb_cb
 sacked field
Date: Mon, 16 Apr 2012 14:49:49 -0400 (EDT)
Message-ID: <20120416.144949.1178765872497298057.davem@davemloft.net>
References: <1334596086-22905-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab2DPStw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 14:49:52 -0400
In-Reply-To: <1334596086-22905-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 16 Apr 2012 13:08:06 -0400

> Commit b82d1bb4 inadvertendly placed unrelated new code between
> TCPCB_EVER_RETRANS and TCPCB_RETRANS and the other macros that refer
> to the sacked field in the struct tcp_skb_cb (probably because there
> was a misleading empty line there). This commit fixes up the
> formatting so that all macros related to the sacked field are adjacent
> again.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied to net-next, thanks Neal.

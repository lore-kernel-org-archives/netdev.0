From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bridge: stp: ensure mac header is set
Date: Mon, 03 Jan 2011 12:10:02 -0800 (PST)
Message-ID: <20110103.121002.242143391.davem@davemloft.net>
References: <1294064188-17722-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752678Ab1ACUJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 15:09:31 -0500
In-Reply-To: <1294064188-17722-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  3 Jan 2011 15:16:28 +0100

> commit bf9ae5386bca8836c16e69ab8fdbe46767d7452a
> (llc: use dev_hard_header) removed the
> skb_reset_mac_header call from llc_mac_hdr_init.
> 
> This seems fine itself, but br_send_bpdu() invokes ebtables LOCAL_OUT.
> 
> We oops in ebt_basic_match() because it assumes eth_hdr(skb) returns
> a meaningful result.
> 
> Cc: acme@ghostprotocols.net
> References: https://bugzilla.kernel.org/show_bug.cgi?id=24532
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks Florian.

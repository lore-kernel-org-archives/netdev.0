From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: br_handle_local_finish should not return
 zero
Date: Tue, 17 Dec 2013 16:13:23 -0500 (EST)
Message-ID: <20131217.161323.1528213413550233056.davem@davemloft.net>
References: <52ACC4F8.6080703@hotsplots.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: faecknitz@hotsplots.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab3LQVNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:13:24 -0500
In-Reply-To: <52ACC4F8.6080703@hotsplots.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Faecknitz <faecknitz@hotsplots.de>
Date: Sat, 14 Dec 2013 21:52:08 +0100

> br_handle_local_finish is called by NF_HOOK(...) after accepting the packet. If
> the return value of NF_HOOK(...) is zero (i.e. the return value of
> br_handle_local_finish), the packet is passed to the network stack. This
> behavior conflicts with netfilter hooks which return NF_STOLEN/NF_QUEUE. In this
> case, NF_HOOK(...) returns also zero (see nf_hook_slow) but
> br_handle_local_finish was never called. The packet will still passed to the
> network stack.
> 
> Signed-off-by: Martin Faecknitz

This is not a proper Signed-off-by: tag, you have to put your name
as well as your email address, similar to how it appears in the
"From: " field of your outgoing emails.

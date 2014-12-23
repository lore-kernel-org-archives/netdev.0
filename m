From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net] net: Reset secmark when scrubbing packet
Date: Tue, 23 Dec 2014 17:28:56 -0200
Message-ID: <1565845.goe1yP4tEB@t520.home>
References: <efb09aca5173a9a18f15066c33a4998ed70bd34a.1419293504.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:49208 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbaLWT3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 14:29:00 -0500
Received: from homiemail-a100.g.dreamhost.com (sub3.mail.dreamhost.com [69.163.253.7])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 0CC658C9DC
	for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 11:29:00 -0800 (PST)
In-Reply-To: <efb09aca5173a9a18f15066c33a4998ed70bd34a.1419293504.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, December 23, 2014 01:13:18 AM Thomas Graf wrote:
> 
> skb_scrub_packet() is called when a packet switches between a context
> such as between underlay and overlay, between namespaces, or between
> L3 subnets.
> 
> While we already scrub the packet mark, connection tracking entry,
> and cached destination, the security mark/context is left intact.
> 
> It seems wrong to inherit the security context of a packet when going
> from overlay to underlay or across forwarding paths.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> net/core/skbuff.c | 1 +
> 1 file changed, 1 insertion(+)

Acked-by: Flavio Leitner <fbl@sysclose.org>

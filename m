From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 2/3] dp83640: use proper function to free transmit
 time stamping packets
Date: Mon, 24 Oct 2011 19:47:25 +0200
Message-ID: <20111024174724.GA1954@netboy.at.omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
 <cover.1319193734.git.richard.cochran@omicron.at>
 <966b346f5f73c0afc48f89686e9ed1f44457074b.1319193734.git.richard.cochran@omicron.at>
 <20111024.025555.265760947744724258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johannes@sipsolutions.net, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57847 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab1JXRrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 13:47:36 -0400
Content-Disposition: inline
In-Reply-To: <20111024.025555.265760947744724258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2011 at 02:55:55AM -0400, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Fri, 21 Oct 2011 12:49:16 +0200
> 
> > The previous commit enforces a new rule for handling the cloned packets
> > for transmit time stamping. These packets must not be freed using any other
> > function than skb_complete_tx_timestamp. This commit fixes the one and only
> > driver using this API.
> > 
> > The driver first appeared in v3.0.
> > 
> > Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: <stable@vger.kernel.org>
> 
> In the 'net' tree, which is where you should be targetting these dp83640
> driver patches, the code looks nothing like what you're patching against.
> 
> Please respin patches #2 and #3 against current sources.

Okay, but #2 will conflict with 

    dccaa9e0 dp83640: add time stamp insertion for sync messages

in net-next. Should I also submit a fix for that one?

Thanks,
Richard

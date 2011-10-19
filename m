From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 16:25:48 +0200
Message-ID: <20111019142548.GA15253@netboy.at.omicron.at>
References: <cover.1318498805.git.richard.cochran@omicron.at>
 <20111019.001610.312990203017422173.davem@davemloft.net>
 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
 <20111019115012.GA7206@netboy.at.omicron.at>
 <1319027881.3103.27.camel@edumazet-laptop>
 <1319029101.4424.36.camel@jlt3.sipsolutions.net>
 <1319030503.8416.11.camel@edumazet-laptop>
 <1319030738.4424.39.camel@jlt3.sipsolutions.net>
 <1319030829.8416.15.camel@edumazet-laptop>
 <1319031173.1286.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58259 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab1JSOZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 10:25:43 -0400
Received: by gyb13 with SMTP id 13so1697584gyb.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 07:25:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1319031173.1286.1.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 03:32:53PM +0200, Johannes Berg wrote:
> 
> OTOH, could skb_clone_tx_timestamp() orphan the original skb after
> adding the skb2?

The Ethernet MAC driver decides what to do with the original skb. In
the MAC driver, it goes like:

1. skb_tx_timestamp(skb) -> skb_clone_tx_timestamp(skb);
2. give skb to hardware;
3. ...
4. kfree_skb, recycle, etc

Richard

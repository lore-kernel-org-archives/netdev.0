From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH V2] net: fix divide by zero in tcp algorithm
 illinois
Date: Wed, 31 Oct 2012 18:14:38 +0100
Message-ID: <1351703678.32673.414.camel@edumazet-glaptop>
References: <20121031124318.30915.32293.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Petr Matousek <pmatouse@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52738 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757067Ab2JaROn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:14:43 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so866385eek.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 10:14:42 -0700 (PDT)
In-Reply-To: <20121031124318.30915.32293.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-31 at 13:45 +0100, Jesper Dangaard Brouer wrote:
> Reading TCP stats when using TCP Illinois congestion control algorithm
> can cause a divide by zero kernel oops.
> 
> The division by zero occur in tcp_illinois_info() at:
>  do_div(t, ca->cnt_rtt);
> where ca->cnt_rtt can become zero (when rtt_reset is called)
> 

> Cc: Petr Matousek <pmatouse@redhat.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 10:25:49 +0200
Message-ID: <1340785549.2028.153.camel@localhost>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <201206270723.11615.hans.schillstrom@ericsson.com>
	 <20120627.012204.1603944185909940692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, eric.dumazet@gmail.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884Ab2F0IZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 04:25:56 -0400
In-Reply-To: <20120627.012204.1603944185909940692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 01:22 -0700, David Miller wrote:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Date: Wed, 27 Jun 2012 07:23:03 +0200
> 
> > On Tuesday 26 June 2012 19:02:36 Eric Dumazet wrote:
> >> With David patch using jhash instead of SHA, I reach ~315.000 SYN per
> >> second.
> > 
> > I have similar results from ~170k to ~199k synack/sec.
> 
> Eric and Hans, I'm going to add Tested-by: tags for both of you
> when I commit this patch if you don't mind. :-)

You can also add my

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

(I agree with you patch, and its does not have an attack vector...)

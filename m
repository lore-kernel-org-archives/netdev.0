From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ppp/l2tp doing oversized allocations ?
Date: Sat, 19 May 2012 07:01:25 +0200
Message-ID: <1337403685.7029.63.camel@edumazet-glaptop>
References: <20120514162923.GA4439@redhat.com>
	 <20120519.004652.2261671316587735315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	kernel-team@fedoraproject.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51537 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094Ab2ESFBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 01:01:30 -0400
Received: by wgbdr13 with SMTP id dr13so3335814wgb.1
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 22:01:29 -0700 (PDT)
In-Reply-To: <20120519.004652.2261671316587735315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-19 at 00:46 -0400, David Miller wrote:

> So it's ESP encapsulated IPSEC over L2tp.
> 
> Eric, I wonder if session->hdr_len can take on undesirable values and
> thus trip up the skb COW'ing calculations you added?

I take a look, thanks

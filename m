From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Wed, 11 Jul 2012 06:44:21 +0200
Message-ID: <1341981861.3265.6740.camel@edumazet-glaptop>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
	 <20120710.210221.559183284956265274.davem@davemloft.net>
	 <1341979678.3265.6660.camel@edumazet-glaptop>
	 <20120710.211304.1112522544390324120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:44246 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613Ab2GKEo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 00:44:26 -0400
Received: by wgbds11 with SMTP id ds11so4211128wgb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 21:44:25 -0700 (PDT)
In-Reply-To: <20120710.211304.1112522544390324120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 21:13 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 11 Jul 2012 06:07:58 +0200
> 
> > I dont think this 8bytes alignment is possible with ip6tables.
> 
> Hmmm, wouldn't it make more sense to make ip6tables use a special
> accessor than to penalize everyone?

But we cannot guarantee 64bit alignment everywhere.

Think of tunnels for example.

I dont see where in demux code we have a 64bit access ?

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] tcp: better TCP_SKB_CB layout to reduce
 cache line misses
Date: Tue, 23 Sep 2014 02:09:27 -0700
Message-ID: <1411463367.26859.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411429844-11099-1-git-send-email-edumazet@google.com>
	 <1411429844-11099-4-git-send-email-edumazet@google.com>
	 <20140923072016.GL3291@cpaasch-mac> <20140923073653.GM3291@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33821 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaIWJJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 05:09:29 -0400
Received: by mail-pa0-f53.google.com with SMTP id hz1so6278749pad.40
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 02:09:29 -0700 (PDT)
In-Reply-To: <20140923073653.GM3291@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-23 at 09:36 +0200, Christoph Paasch wrote:
> On 23/09/14 - 09:20:16, Christoph Paasch wrote:
> > Hello Eric,
...
> > doesn't also the tx-path relies on IPCB(skb) being memset to 0 (e.g., in
> > xfrm4_output or ip_options_build)
> 
> Crap, forget about ip_options_build. It is memcpy'ing into IPCB... Confused
> src with dest... :-)
> 
> Nevertheless, wouldn't there be a problem in xfrm4_output?

Hi Christoph.

I believe you're right. I'll include a memset() in v2.
 
Thanks !

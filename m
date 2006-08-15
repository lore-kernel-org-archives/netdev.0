From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Tue, 15 Aug 2006 21:49:06 +0400
Message-ID: <20060815174906.GA28805@2ka.mipt.ru>
References: <20060814123530.GA5019@2ka.mipt.ru> <1155639302.5696.210.camel@twins> <20060815112617.GB21736@2ka.mipt.ru> <1155643405.5696.236.camel@twins> <20060815123438.GA29896@2ka.mipt.ru> <1155649768.5696.262.camel@twins> <20060815141501.GA10998@2ka.mipt.ru> <1155653339.5696.282.camel@twins> <20060815150507.GA9734@2ka.mipt.ru> <1155663737.13508.127.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60558 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030407AbWHORtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 13:49:42 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Disposition: inline
In-Reply-To: <1155663737.13508.127.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 07:42:16PM +0200, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> Right, however I just realised that most storage protocols (level 7)
> have their own ACK msgs and do not rely on TCP (level 4) ACKs like this.
> 
> So I would like to come back on this, I do need a full data channel
> open.

In that case you can not solve problem with emergensy pool until you
mark all needed sockets as capable to do it.
Global socket limits are still there in sk_stream_alloc_pskb().

-- 
	Evgeniy Polyakov

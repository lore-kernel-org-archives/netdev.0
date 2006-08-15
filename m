From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Tue, 15 Aug 2006 19:42:16 +0200
Message-ID: <1155663737.13508.127.camel@lappy>
References: <20060814110359.GA27704@2ka.mipt.ru>
	 <1155558313.5696.167.camel@twins> <20060814123530.GA5019@2ka.mipt.ru>
	 <1155639302.5696.210.camel@twins> <20060815112617.GB21736@2ka.mipt.ru>
	 <1155643405.5696.236.camel@twins> <20060815123438.GA29896@2ka.mipt.ru>
	 <1155649768.5696.262.camel@twins> <20060815141501.GA10998@2ka.mipt.ru>
	 <1155653339.5696.282.camel@twins>  <20060815150507.GA9734@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:52436 "EHLO
	amsfep15-int.chello.nl") by vger.kernel.org with ESMTP
	id S1030396AbWHORm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 13:42:26 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060815150507.GA9734@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 19:05 +0400, Evgeniy Polyakov wrote:

> > Not sure on the details; but you say: when we reach the threshold all
> > following packets will be dropped. So if you provide enough memory to
> > exceed the limit, you have some extra. If you then use that extra bit to
> > allow ACKs to pass through, then you're set.
> > 
> > Sounds good, but you'd have to carve a path for the ACKs, right? Or is
> > that already there?
> 
> Acks with or without attached data are processed before data queueing.
> See tcp_rcv_established().

Right, however I just realised that most storage protocols (level 7)
have their own ACK msgs and do not rely on TCP (level 4) ACKs like this.

So I would like to come back on this, I do need a full data channel
open.


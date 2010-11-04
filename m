From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] net: reset gso header when the copied skb is linearized
Date: Thu, 4 Nov 2010 18:35:27 -0200
Message-ID: <20101104203527.GA21935@redhat.com>
References: <1288045398-3110-1-git-send-email-fleitner@redhat.com>
 <20101026.113157.233700961.davem@davemloft.net>
 <20101026192511.GA3494@redhat.com>
 <20101026.122801.52191238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752305Ab0KDUff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 16:35:35 -0400
Content-Disposition: inline
In-Reply-To: <20101026.122801.52191238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 12:28:01PM -0700, David Miller wrote:
> From: Flavio Leitner <fleitner@redhat.com>
> Date: Tue, 26 Oct 2010 17:25:11 -0200
> 
> > If I understand that correctly, the gso_segs is the number
> > of GSO segments which are divided in non-linear way. When the
> > copy is made using that function, the skb turns into a big
> > one segment inlined. So, the idea of segments is lost and
> > I'm not seeing how it is going to be divided again. 
> > Later the NIC drives does, for example:
> 
> GSO has nothing to do with linearity, although it just so happens
> to be that GSO packets tend to be non-linear due to the way
> TCP builds such frames.
> 
> The GSO segment count is the number of MSS sized frames are
> contained inside of a larger than MSS sized SKB.
> 
> That is it.  So the definition and meaning is independent of
> linearity.
> 
> Thus, if we linearize a larger than MSS sized frame, it should still
> have the same GSO attributes.

It makes sense, thanks for the explanation.
Please ignore the proposed patch.

thanks again,
-- 
Flavio

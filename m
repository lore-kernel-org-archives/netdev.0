From: David Miller <davem@davemloft.net>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Wed, 14 Oct 2009 15:43:49 -0700 (PDT)
Message-ID: <20091014.154349.83940908.davem@davemloft.net>
References: <20091014045226.GA15655@1wt.eu>
	<Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
	<20091014201706.GA24298@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932113AbZJNWnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 18:43:53 -0400
In-Reply-To: <20091014201706.GA24298@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Wed, 14 Oct 2009 22:17:06 +0200

> Hello Julian,
> 
> On Wed, Oct 14, 2009 at 10:27:50AM +0300, Julian Anastasov wrote:
>> The semantic 'TCP_DEFER_ACCEPT extends the period after ACK'
>> is good, you can tune it together with TCP_SYNCNT, to
>> extend or not to extend the period. What happens on
>> TCP_DEFER_ACCEPT expiration after ACK - we all prefer to
>> see FIN, so we have to wait someone to come with new
>> implementation.
> 
> Well, too much complicated for very little gain IMHO.

For now I'm pushing Willy's change into Linus's tree.

After more discussion we can revert if necessary.

I won't submit this to -stable until the discussion is fully resolved.

Thanks!

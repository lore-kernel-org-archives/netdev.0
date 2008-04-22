From: David Miller <davem@davemloft.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
 version of Tomasz's patch set
Date: Tue, 22 Apr 2008 15:06:48 -0700 (PDT)
Message-ID: <20080422.150648.158484938.davem@davemloft.net>
References: <200804211817.01189.tomasz@grobelny.oswiecenia.net>
	<480D6FFA.80205@trash.net>
	<200804222245.53322.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, acme@redhat.com, gerrit@erg.abdn.ac.uk,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: tomasz@grobelny.oswiecenia.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757167AbYDVWGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 18:06:48 -0400
In-Reply-To: <200804222245.53322.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 22 Apr 2008 22:45:53 +0200

> Maybe I wasn't clear enough with my question. I understand that
> these two memsets would have to be readded. But my question is: did
> you identify any bugs that were caused by junk in skb->cb before
> applying your patch? If so, do you have any test cases? It could
> help to check code for correctness if one day more space in skb->cb
> will be needed (which of course doesn't have to be in the nearest
> future).

I think Patrick noticed it because it broke netfilter.

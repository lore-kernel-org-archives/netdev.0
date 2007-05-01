From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 13:53:40 -0400
Message-ID: <20070501175340.GD1751@kvack.org>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org> <20070501174126.GA7577@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:36772 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755179AbXEARxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 13:53:49 -0400
Content-Disposition: inline
In-Reply-To: <20070501174126.GA7577@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 09:41:28PM +0400, Evgeniy Polyakov wrote:
> Hmm, 2.2 machine in your test seems to behave incorrectly:

I am aware of that.  However, I think that the loss of certain packets and 
reordering can result in the same behaviour.  What's more, is that this 
behaviour can occur in real deployed systems.  "Be strict in what you send 
and liberal in what you accept."  Both systems should be fixed, which is 
what I'm trying to do.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.

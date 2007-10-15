From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix csum_start update in pskb_expand_head
Date: Mon, 15 Oct 2007 01:46:34 -0700 (PDT)
Message-ID: <20071015.014634.58769774.davem@davemloft.net>
References: <20071014192640.35065e73@inria.fr>
	<20071014222037.7fa28640@inria.fr>
	<20071015045723.GA28388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guichaz@yahoo.fr, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752915AbXJOIqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:46:30 -0400
In-Reply-To: <20071015045723.GA28388@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 15 Oct 2007 12:57:23 +0800

> On Sun, Oct 14, 2007 at 08:20:37PM +0000, Guillaume Chazarain wrote:
> > 
> > Just another data point, it seems that running the standard Bittorrent
> > client helps triggering the bug.
> 
> Doh! It was my patch a month ago which added code to update
> csum_start if the headroom changed that broke this.
> 
> We'll need this patch for stable as well.
> 
> [NET]: Fix csum_start update in pskb_expand_head
> 
> I got confused by the dual nature of the off variable in the
> function pskb_expand_head.  The csum_start offset should use
> nhead instead of off which can change depending on whether we
> are using offsets or pointers.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and I'll take care of the -stable submission.

From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 3/3] bridge: send query as soon as leave is
 received
Date: Mon, 29 Apr 2013 16:15:54 +0800
Message-ID: <1367223354.2479.2.camel@cr0>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
	 <1367220392-17496-3-git-send-email-amwang@redhat.com>
	 <20130429074358.GB14021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab3D2IQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 04:16:17 -0400
In-Reply-To: <20130429074358.GB14021@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 15:43 +0800, Herbert Xu wrote:
> On Mon, Apr 29, 2013 at 03:26:32PM +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > Continue sending queries when leave is received if the user marks
> > it as a querier.
> 
> If we're going to send a query on leave it should be group-specific
> and not general.
> 

Right, I will fix it.

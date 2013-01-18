From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [Patch net-next 3/2] xfrm: use separated locks to protect
 pointers of struct xfrm_state_afinfo
Date: Fri, 18 Jan 2013 09:54:30 +0100
Message-ID: <20130118085430.GF24987@secunet.com>
References: <1358323506-19571-2-git-send-email-amwang@redhat.com>
 <1358411651-3579-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45542 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759Ab3ARIye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 03:54:34 -0500
Content-Disposition: inline
In-Reply-To: <1358411651-3579-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 04:34:11PM +0800, Cong Wang wrote:
> (On top of my previous RCU convert patches)
> 
> afinfo->type_map and afinfo->mode_map deserve separated locks,
> they are different things.
> 
> We should just take RCU read lock to protect afinfo itself,
> but not for the inner pointers.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

All Aplied to ipsec-next, thanks!

From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: fix freed block size calculation in
 xfrm_policy_fini()
Date: Mon, 21 Jan 2013 13:02:31 +0100
Message-ID: <20130121120231.GA9147@secunet.com>
References: <20130118153446.3AE05C1AFE@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47360 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573Ab3AUMCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 07:02:34 -0500
Content-Disposition: inline
In-Reply-To: <20130118153446.3AE05C1AFE@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 04:03:48PM +0100, Michal Kubecek wrote:
> Missing multiplication of block size by sizeof(struct hlist_head)
> can cause xfrm_hash_free() to be called with wrong second argument
> so that kfree() is called on a block allocated with vzalloc() or
> __get_free_pages() or free_pages() is called with wrong order when
> a namespace with enough policies is removed.
> 
> Bug introduced by commit a35f6c5d, i.e. versions >= 2.6.29 are
> affected.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied, Thanks!

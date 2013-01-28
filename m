From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [Patch net-next] af_key: remove a duplicated skb_orphan()
Date: Mon, 28 Jan 2013 11:02:05 +0100
Message-ID: <20130128100205.GP9147@secunet.com>
References: <1358952747-3772-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58889 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226Ab3A1KCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 05:02:11 -0500
Content-Disposition: inline
In-Reply-To: <1358952747-3772-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 10:52:27PM +0800, Cong Wang wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> skb_set_owner_r() will call skb_orphan(), I don't
> see any reason to call it twice.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 

Applied to ipsec-next, thanks!

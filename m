From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] macvtap: advance iov iterator when needed in
 macvtap_put_user()
Date: Thu, 20 Nov 2014 16:34:26 +0800
Message-ID: <20141120083426.GA30001@gondor.apana.org.au>
References: <1416472265-10151-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35364 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbaKTIed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 03:34:33 -0500
Content-Disposition: inline
In-Reply-To: <1416472265-10151-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 04:31:05PM +0800, Jason Wang wrote:
> When mergeable buffer is used, vnet_hdr_sz is greater than sizeof struct
> virtio_net_hdr. So we need advance the iov iterators in this case.
> 
> Fixes 6c36d2e26cda1ad3e2c4b90dd843825fc62fe5b4 ("macvtap: Use iovec iterators")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

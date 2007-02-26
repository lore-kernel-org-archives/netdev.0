From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH, RESEND] chelsio: Fix non-NAPI compile
Date: Mon, 26 Feb 2007 15:00:00 -0800
Message-ID: <20070226150000.45347455@freekitty>
References: <20070220235759.102686172@linux-foundation.org>
	<adamz38c55r.fsf@cisco.com>
	<ada1wkczfti.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37146 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161334AbXBZXAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 18:00:04 -0500
In-Reply-To: <ada1wkczfti.fsf_-_@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Feb 2007 14:58:49 -0800
Roland Dreier <rdreier@cisco.com> wrote:

> Chelsio without NAPI enabled has been broken (won't compile) since
> 3de00b89 ("chelsio: NAPI speed improvement"):
> 
>     drivers/net/chelsio/sge.c: In function `t1_interrupt`:
>     drivers/net/chelsio/sge.c:1716: error: `Q` undeclared (first use in this function)
> 
> The change below seems to add back in the declaration and
> initialization of `Q` that was removed by mistake, and at least makes
> the driver compile for me, although I have no hardware and hence no
> way to test whether this actually works.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
> Jeff, I haven't seen any response from Stephen but Divy from Chelsio
> seemed to agree with this patch, so can you please merge it?  Right
> now the build is broken with CONFIG_CHELSIO_T1_NAPI=n.
> 
> Thanks.
> 
> 

I agree it was an obvious goof.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

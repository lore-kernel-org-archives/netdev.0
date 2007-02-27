From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH, RESEND] chelsio: Fix non-NAPI compile
Date: Tue, 27 Feb 2007 04:28:07 -0500
Message-ID: <45E3F9A7.4000706@garzik.org>
References: <20070220235759.102686172@linux-foundation.org> <adamz38c55r.fsf@cisco.com> <ada1wkczfti.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47548 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161090AbXB0J2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:28:10 -0500
In-Reply-To: <ada1wkczfti.fsf_-_@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
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

applied



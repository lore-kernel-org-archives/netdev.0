From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 2/3] sctp: return back transport in
 __sctp_rcv_init_lookup
Date: Fri, 28 Oct 2016 19:39:43 -0200
Message-ID: <20161028213943.GA14175@localhost.localdomain>
References: <cover.1477649076.git.lucien.xin@gmail.com>
 <5ebf537ea021af594ca1b2538d28a3080d5c3ee7.1477649076.git.lucien.xin@gmail.com>
 <20161028194221.GC4193@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51960 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761948AbcJ1Vjx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 17:39:53 -0400
Content-Disposition: inline
In-Reply-To: <20161028194221.GC4193@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2016 at 05:42:21PM -0200, Marcelo Ricardo Leitner wrote:
> On Fri, Oct 28, 2016 at 06:10:53PM +0800, Xin Long wrote:
> > Prior to this patch, it used a local variable to save the transport that is
> > looked up by __sctp_lookup_association(), and didn't return it back. But in
> > sctp_rcv, it is used to initialize chunk->transport. So when hitting this
> > code, it was initializing chunk->transport with some random stack value
> > instead.
> > 
> > This patch is to return the transport back through transport pointer
> > that is from __sctp_rcv_lookup_harder().
> > 
> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> 
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> transport pointer in sctp_rcv() is initialized to null and there are
> checks for it after this path, so this shouldn't be exploitable, just
> malfunction.

This actually sort of contradicts the changelog.

Xin, did I miss something here? Seems we need to update the changelog if
not.

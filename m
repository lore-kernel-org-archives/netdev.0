From: marcelo.leitner@gmail.com
Subject: Re: [PATCHv2 net] sctp: return back transport in
 __sctp_rcv_init_lookup
Date: Mon, 31 Oct 2016 18:13:02 -0200
Message-ID: <20161031201302.GB8514@localhost.localdomain>
References: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477845755.git.lucien.xin@gmail.com>
 <20161031.155348.689672413057243931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55692 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S946296AbcJaUNG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 16:13:06 -0400
Content-Disposition: inline
In-Reply-To: <20161031.155348.689672413057243931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 03:53:48PM -0400, David Miller wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Mon, 31 Oct 2016 00:42:35 +0800
> 
> > Prior to this patch, it used a local variable to save the transport that is
> > looked up by __sctp_lookup_association(), and didn't return it back. But in
> > sctp_rcv, it is used to initialize chunk->transport. So when hitting this,
> > even if it found the transport, it was still initializing chunk->transport
> > with null instead.
> > 
> > This patch is to return the transport back through transport pointer
> > that is from __sctp_rcv_lookup_harder().
> > 
> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> 
> So do I apply this to 'net'?  If so I'd like to see explicit ACKs.
> 
> Thanks.

No. Xin reposted the patchset with this patch updated instead, so please
ignore this one. Thanks.

Patchset named: [PATCHv2 net 0/3] sctp: a bunch of fixes by holding transport

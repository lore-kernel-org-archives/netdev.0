From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net] sctp: return back transport in
 __sctp_rcv_init_lookup
Date: Mon, 31 Oct 2016 08:51:55 -0200
Message-ID: <20161031105155.GA8514@localhost.localdomain>
References: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477845755.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56624 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936045AbcJaKv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 06:51:59 -0400
Content-Disposition: inline
In-Reply-To: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477845755.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 12:42:35AM +0800, Xin Long wrote:
> Prior to this patch, it used a local variable to save the transport that is
> looked up by __sctp_lookup_association(), and didn't return it back. But in
> sctp_rcv, it is used to initialize chunk->transport. So when hitting this,
> even if it found the transport, it was still initializing chunk->transport
> with null instead.
> 
> This patch is to return the transport back through transport pointer
> that is from __sctp_rcv_lookup_harder().
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---

Patch looks good now but you have to either repost the entire series
altogether, or repost the series to remove this patch from it.

  Marcelo

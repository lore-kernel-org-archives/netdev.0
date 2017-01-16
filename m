From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: remove useless code from
 sctp_apply_peer_addr_params
Date: Mon, 16 Jan 2017 13:52:57 -0500 (EST)
Message-ID: <20170116.135257.361979191382843875.davem@davemloft.net>
References: <99bc9f227c4c857d2bb258391231231d46c1899d.1484336556.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        vyasevich@gmail.com, nhorman@tuxdriver.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdAPSw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:52:58 -0500
In-Reply-To: <99bc9f227c4c857d2bb258391231231d46c1899d.1484336556.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 13 Jan 2017 18:31:15 -0200

> sctp_frag_point() doesn't store anything, and thus just calling it
> cannot do anything useful.
> 
> sctp_apply_peer_addr_params is only called by
> sctp_setsockopt_peer_addr_params. When operating on an asoc,
> sctp_setsockopt_peer_addr_params will call sctp_apply_peer_addr_params
> once for the asoc, and then once for each transport this asoc has,
> meaning that the frag_point will be recomputed when updating the
> transports and calling it when updating the asoc is not necessary.
> IOW, no action is needed here and we can remove this call.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, but please put "[PATCH net-next v2]" or some other indication
in your Subject line so that new revisions of a patch are easily
discernable.

Thanks.

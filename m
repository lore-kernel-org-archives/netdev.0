From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] sctp: Remove some redundant code
Date: Mon, 19 Sep 2016 01:34:34 -0400 (EDT)
Message-ID: <20160919.013434.1910609314182367829.davem@davemloft.net>
References: <1474059935-17343-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755785AbcISFej (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:34:39 -0400
In-Reply-To: <1474059935-17343-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Fri, 16 Sep 2016 23:05:35 +0200

> In commit 311b21774f13 ("sctp: simplify sk_receive_queue locking"), a call
> to 'skb_queue_splice_tail_init()' has been made explicit. Previously it was
> hidden in 'sctp_skb_list_tail()'
> 
> Now, the code around it looks redundant. The '_init()' part of
> 'skb_queue_splice_tail_init()' should already do the same.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next.

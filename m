From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/9] net: Do txq_trans_update() in netdev_start_xmit()
Date: Tue, 2 Sep 2014 08:54:32 +0200
Message-ID: <20140902085432.2e5ff962@redhat.com>
References: <20140901.152438.1000592701792724604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848AbaIBGyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 02:54:37 -0400
In-Reply-To: <20140901.152438.1000592701792724604.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Sep 2014 15:24:38 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> That way we don't have to audit every call site to make sure it is
> doing this properly.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/wan/dlci.c    |  6 ++++--

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Nicely done, even caught that wan/dlci.c were not calling txq_trans_update(txq).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

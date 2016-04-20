From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: Split SW RX dropped counter per RX
 ring
Date: Wed, 20 Apr 2016 07:56:49 -0700
Message-ID: <1461164209.10638.262.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
	 <1461157278-18528-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33588 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531AbcDTO4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 10:56:51 -0400
Received: by mail-pf0-f170.google.com with SMTP id 184so19271859pff.0
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 07:56:51 -0700 (PDT)
In-Reply-To: <1461157278-18528-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-20 at 16:01 +0300, Or Gerlitz wrote:
> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> Count SW packet drops per RX ring instead of a global counter. This
> will allow monitoring the number of rx drops per ring.
> 
> In addition, SW rx_dropped counter was overwritten by HW rx_dropped
> counter, sum both of them instead to show the accurate value.
> 
> Fixes: a3333b35da16 ('net/mlx4_en: Moderate ethtool callback to [...] ')
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---

Reported-by: Eric Dumazet <edumazet@google.com>

( http://www.spinics.net/lists/netdev/msg371318.html )

Thanks for following up !

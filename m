From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next V2 2/2] pktgen: Specify the index of first
 thread
Date: Thu, 15 Jun 2017 21:24:11 +0200
Message-ID: <20170615212411.7b201f5a@redhat.com>
References: <1497542842-13721-1-git-send-email-tariqt@mellanox.com>
        <1497542842-13721-3-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>, brouer@redhat.com
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54362 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751578AbdFOTYR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 15:24:17 -0400
In-Reply-To: <1497542842-13721-3-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 19:07:22 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> Use "-f <num>", to specify the index of the first
> sender thread.
> In default first thread is #0.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
[...]
>  
> +export L_THREAD=$(( THREADS + F_THREAD - 1 ))
> +

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

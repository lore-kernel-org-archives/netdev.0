From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 2/4] macvtap: Consistently use rcu functions
Date: Tue, 25 Jun 2013 13:31:52 -0700
Message-ID: <1372192312.3301.121.camel@edumazet-glaptop>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
	 <1372190662-30815-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:62283 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab3FYUbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 16:31:40 -0400
Received: by mail-ee0-f52.google.com with SMTP id c50so6978808eek.39
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 13:31:39 -0700 (PDT)
In-Reply-To: <1372190662-30815-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 16:04 -0400, Vlad Yasevich wrote:
> Currently macvtap uses rcu_bh functions in its
> user facing fuction macvtap_get_user() and macvtap_put_user().
> However, its packet handlers use normal rcu as the rcu_read_lock()
> is taken in netif_receive_skb().  We can safely discontinue
> the usage or rcu with bh disabled.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvtap.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)

Reviewed-by: Eric Dumazet <edumazet@google.com>

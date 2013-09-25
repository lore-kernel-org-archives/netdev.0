From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Wed, 25 Sep 2013 04:56:03 -0700
Message-ID: <1380110163.3165.138.camel@edumazet-glaptop>
References: <20130925055418.GV7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:45661 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755119Ab3IYL4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 07:56:06 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so5956748pbc.29
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 04:56:05 -0700 (PDT)
In-Reply-To: <20130925055418.GV7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-25 at 07:54 +0200, Steffen Klassert wrote:
> We might extend the used aera of a skb beyond the total
> headroom when we install the ipip header. Fix this by
> calling skb_cow_head() unconditionally.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/ip_tunnel.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)

Do you know or can we find when was the bug introduced ?

(commit id and title in your changelog would be really nice)

Thanks !

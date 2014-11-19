From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] packet: make packet_snd fail on len smaller
 than l2 header
Date: Wed, 19 Nov 2014 10:25:06 -0800
Message-ID: <1416421506.14060.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416420616-5029-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, dborkman@redhat.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:45678 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554AbaKSSZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:25:08 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so3437404igd.2
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 10:25:08 -0800 (PST)
In-Reply-To: <1416420616-5029-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-19 at 13:10 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When sending packets out with PF_PACKET, SOCK_RAW, ensure that the
> packet is at least as long as the device's expected link layer header.
> This check already exists in tpacket_snd, but not in packet_snd.
> Also rate limit the warning in tpacket_snd.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Willem

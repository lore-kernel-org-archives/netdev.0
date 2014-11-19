From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] packet: make packet_snd fail on len smaller
 than l2 header
Date: Wed, 19 Nov 2014 19:31:40 +0100
Message-ID: <546CE20C.5000506@redhat.com>
References: <1416420616-5029-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754203AbaKSSbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 13:31:53 -0500
In-Reply-To: <1416420616-5029-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2014 07:10 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> When sending packets out with PF_PACKET, SOCK_RAW, ensure that the
> packet is at least as long as the device's expected link layer header.
> This check already exists in tpacket_snd, but not in packet_snd.
> Also rate limit the warning in tpacket_snd.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Looks good to me, thanks!

Acked-by: Daniel Borkmann <dborkman@redhat.com>

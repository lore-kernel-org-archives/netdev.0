From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Wed, 08 Oct 2014 00:03:37 +0200
Message-ID: <54346339.3000509@redhat.com>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbaJGWDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 18:03:44 -0400
In-Reply-To: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2014 10:30 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Support skb->xmit_more in i40e is straightforward : we need to move
> around i40e_maybe_stop_tx() call to correctly test netif_xmit_stopped()
> before taking the decision to not kick the NIC.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Jeff, feel free to drop the same version I've sent you yesterday
directly since this here is already in patchwork ...

Thanks, Eric!

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

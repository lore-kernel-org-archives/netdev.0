From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: Remove 'unlikely' qualifier in
 skb_steal_sock()
Date: Mon, 25 Jun 2012 08:09:37 +0200
Message-ID: <1340604577.23933.23.camel@edumazet-glaptop>
References: <1340578987-2495-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.h.duyck@intel.com, shemminger@vyatta.com
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42014 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab2FYGJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:09:52 -0400
Received: by eeit10 with SMTP id t10so1053049eei.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 23:09:51 -0700 (PDT)
In-Reply-To: <1340578987-2495-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-24 at 16:03 -0700, Vijay Subramanian wrote:
> With early demux enabled by default for TCP flows, there is high chance that
> skb->sk will be non-null. 'unlikely()' was removed from __inet_lookup_skb() but
> maybe it can be removed from skb_steal_sock() as well.
> 
> Note: skb_steal_sock() is also called by __inet6_lookup_skb() and
> __udp4_lib_lookup_skb() but they are protected by their own 'unlikely' calls.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/5] net: Extend struct flowi6 with multipath
 hash
Date: Mon, 24 Oct 2016 11:39:29 +0200
Message-ID: <68209ce2-749c-ef7e-08a7-6414d2ba680c@stressinduktion.org>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
 <1477301332-23954-3-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: Jakub Sitnicki <jkbs@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:51445 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755264AbcJXJjc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 05:39:32 -0400
In-Reply-To: <1477301332-23954-3-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.10.2016 11:28, Jakub Sitnicki wrote:
> Allow for functions that fill out the IPv6 flow info to also pass a hash
> computed over the skb contents. The hash value will drive the multipath
> routing decisions.
> 
> This is intended for special treatment of ICMPv6 errors, where we would
> like to make a routing decision based on the flow identifying the
> offending IPv6 datagram that triggered the error, rather than the flow
> of the ICMP error itself.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

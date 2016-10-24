From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded
 ICMP errors from offending packet
Date: Mon, 24 Oct 2016 11:43:03 +0200
Message-ID: <6e04414c-3fe0-f4e4-4c0a-65fdce95e859@stressinduktion.org>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
 <1477301332-23954-6-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Jakub Sitnicki <jkbs@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58592 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S936515AbcJXJnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 05:43:06 -0400
In-Reply-To: <1477301332-23954-6-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.10.2016 11:28, Jakub Sitnicki wrote:
> Same as for the transmit path, let's do our best to ensure that received
> ICMP errors that may be subject to forwarding will be routed the same
> path as flow that triggered the error, if it was going in the opposite
> direction.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

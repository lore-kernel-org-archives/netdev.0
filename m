From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Wed, 02 Nov 2016 18:17:32 +0100
Message-ID: <1478107052.1833947.775286313.0A06B9DC@webmail.messagingengine.com>
References: <1478104158-9504-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Lance Richardson <lrichard@redhat.com>, netdev@vger.kernel.org,
        fw@strlen.de, jtluka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:51383 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933374AbcKBRRd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 13:17:33 -0400
In-Reply-To: <1478104158-9504-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 2, 2016, at 17:29, Lance Richardson wrote:
> Some configurations (e.g. geneve interface with default
> MTU of 1500 over an ethernet interface with 1500 MTU) result
> in the transmission of packets that exceed the configured MTU.
> While this should be considered to be a "bad" configuration,
> it is still allowed and should not result in the sending
> of packets that exceed the configured MTU.
> 
> Fix by dropping the assumption in ip_finish_output_gso() that
> locally originated gso packets will never need fragmentation.
> Basic testing using iperf (observing CPU usage and bandwidth)
> have shown no measurable performance impact for traffic not
> requiring fragmentation.
> 
> Fixes: c7ba65d7b649 ("net: ip: push gso skb forwarding handling down the
> stack")
> Reported-by: Jan Tluka <jtluka@redhat.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

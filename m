From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: handle no dst on skb in icmp6_send
Date: Thu, 08 Dec 2016 15:04:17 +0100
Message-ID: <1481205857.4073547.812616921.223287BE@webmail.messagingengine.com>
References: <1480301573-21183-1-git-send-email-dsa@cumulusnetworks.com>
 <20161128.161344.1778661062306703117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33361 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752078AbcLHOES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 09:04:18 -0500
In-Reply-To: <20161128.161344.1778661062306703117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On Mon, Nov 28, 2016, at 22:13, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 27 Nov 2016 18:52:53 -0800
> 
> > Andrey reported the following while fuzzing the kernel with syzkaller:
>  ...
> > icmp6_send / icmpv6_send is invoked for both rx and tx paths. In both
> > cases the dst->dev should be preferred for determining the L3 domain
> > if the dst has been set on the skb. Fallback to the skb->dev if it has
> > not. This covers the case reported here where icmp6_send is invoked on
> > Rx before the route lookup.
> > 
> > Fixes: 5d41ce29e ("net: icmp6_send should use dst dev to determine L3 domain")
> > Reported-by: Andrey Konovalov <andreyknvl@google.com>
> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Applied, thanks David.

could you queue this patch up for stable. You can remotely kill machines
with this bug.

Thanks,
Hannes

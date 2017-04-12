From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Wed, 12 Apr 2017 10:08:22 +1000
Message-ID: <1491955702.7236.32.camel@kernel.crashing.org>
References: <20170411.112733.1412982560568816717.davem@davemloft.net>
         <1491948401.7236.20.camel@kernel.crashing.org>
         <1491953765.7236.28.camel@kernel.crashing.org>
         <20170411.200347.823503315758200310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40125 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752290AbdDLAIl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 20:08:41 -0400
In-Reply-To: <20170411.200347.823503315758200310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 20:03 -0400, David Miller wrote:
> > From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Wed, 12 Apr 2017 09:36:05 +1000
> 
> > I should call the helper when I don't recognize the protocol type in
> > the IP header, not just when the main skb protocol type is not IP.
> 
> That's correct.
> 
> > BTW. I'm not too familiar with how encapsulation works these days. I
> > wouldn't throw at that HW anything other than unencapsulated packets
> > for HW checksumming. Is checking skb->protocol to be IP and
> > ip_hdr(skb)->protocol to be IP, UDP or TCP enough ? IE. Will the latter
> > especially return the outer header ?
> 
> If skb->protocol is IP then yes ip_hdr() will point at the outermost
> header.

Great thanks. I'll repost later today in case some other comments still
come in.

Cheers,
Ben.

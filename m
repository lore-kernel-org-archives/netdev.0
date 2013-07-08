From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] xen-netfront: pull on receive skb may need to
 happen earlier
Date: Mon, 08 Jul 2013 13:41:44 +0100
Message-ID: <51DACFA802000078000E343D@nat28.tlf.novell.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
 <20130705145319.GB9050@zion.uk.xensource.com>
 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
 <51DAAD92.4010708@hunenet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>, <davem@davemloft.net>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>
To: "Dion Kant" <g.w.kant@hunenet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:48193 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab3GHMlv convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Mon, 8 Jul 2013 08:41:51 -0400
In-Reply-To: <51DAAD92.4010708@hunenet.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 08.07.13 at 14:16, Dion Kant <g.w.kant@hunenet.nl> wrote:
> I was wondering about the following.
> 
> In netif_poll(struct napi_struct *napi, int budget) the skb->cb is assigend,
> but it may be clipped to RX_COPY_THRESHOLD
> 
> 		NETFRONT_SKB_CB(skb)->pull_to = rx->status;
> 		if (NETFRONT_SKB_CB(skb)->pull_to > RX_COPY_THRESHOLD)
> 		      NETFRONT_SKB_CB(skb)->pull_to = RX_COPY_THRESHOLD;
> 
> How does this modification of NETFRONT_SKB_CB(skb)->pull_to propagates
> or is this irrelevant?

I'm not sure I understand what you're asking. pull_to is a private
(to netfront) field used to communicate how much of the skb
needs to be pulled. I don't see how the word "propagate" makes
any sense here, but as said I may simply not be getting what
you're asking about.

Jan

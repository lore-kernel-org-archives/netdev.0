From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: WARNING (skb_gso_segment) with tg3+bridge in 2.6.27
Date: Thu, 23 Oct 2008 10:13:25 -0700
Message-ID: <1224782005.9142.2.camel@HP1>
References: <20081011172002.GA12659@pest>
 <20081013.004226.171259546.davem@davemloft.net>
 <20081022074502.GA25058@gondor.apana.org.au>
 <20081022175704.GA25286@xw6200.broadcom.net>
 <20081023022001.GB304@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"berni@birkenwald.de" <berni@birkenwald.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3792 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbYJWRPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 13:15:42 -0400
In-Reply-To: <20081023022001.GB304@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-10-22 at 19:20 -0700, Herbert Xu wrote:
> What I meant is the NETIF_F_TSO6 bit vs. NETIF_F_IPV6_CSUM bit.
> My question is essentially does having the first bit always mean
> that the second bit is set.  The second bit stands for support
> of TCPv6 and UDPv6 checksum offload (which is not necessarily
> related to TSO or UFO).
> 
> The thing which I wasn't sure about is that the conditions which
> determine which one of these bits are set do not look the same
> in tg3.
> 

Yes, NETIF_F_TSO6 chips are a subset of NETIF_F_IPV6_CSUM chips.  In the
code, these 2 bits are set independently and so the relationship is not
obvious.  We should probably rearrange the code to make things more
clear.

Thanks.



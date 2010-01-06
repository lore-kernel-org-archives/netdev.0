From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH alt.2] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 20:40:17 +0100
Message-ID: <20100106194017.GA3354@del.dom.local>
References: <20100105230746.GA6612@del.dom.local>
 <4B43F72C.9090004@majjas.com>
 <20100106072208.GA6711@ff.dom.local>
 <20100106091532.GA10201@ff.dom.local>
 <20100106064957.3be271b8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:20113 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014Ab0AFTkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 14:40:25 -0500
Content-Disposition: inline
In-Reply-To: <20100106064957.3be271b8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 06:49:57AM -0800, Stephen Hemminger wrote:
> On Wed, 6 Jan 2010 09:15:32 +0000
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > tpacket_snd() can change and kfree an skb after dev_queue_xmit(),
> > which is illegal.
> > 
> > With debugging by: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > Reported-by: Michael Breuer <mbreuer@majjas.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Good catch.
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

First of all, we're incredibly lucky that such a helpful guy as
Michael had misfortune to hit so helpfully broken piece of hardware ;-)

Thanks,
Jarek P.

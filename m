From: Willy Tarreau <w@1wt.eu>
Subject: Re: ARM network performance and dma_mask
Date: Thu, 21 Nov 2013 23:13:10 +0100
Message-ID: <20131121221310.GG18513@1wt.eu>
References: <20131119174323.GH913@1wt.eu> <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com> <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org> <20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org> <20131120215435.GT8581@1wt.eu> <20131121004430.GX8581@1wt.eu> <20131121183834.GB18513@1wt.eu> <528E82C6.2010106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, edumazet@google.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:51054 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755201Ab3KUWNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 17:13:38 -0500
Content-Disposition: inline
In-Reply-To: <528E82C6.2010106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 04:01:42PM -0600, Rob Herring wrote:
> The patch was to fix this issue[1]. It is fixed in the core code because
> dma_mask not being set has been a known issue with DT probing for some
> time. Since most drivers don't seem to care, we've gotten away with it.
> I thought the normal failure mode was drivers failing to probe.

It seems that very few drivers try to set their mask, so probably that
the default value was already OK even though less performant.

> As to why it helps performance, I'm not really sure. Perhaps it is
> causing some bounce buffers to be used.

That's also the thing I have been thinking about, and given this device
only has a 16-bit DDR bus, bounce buffers can make a difference.

> Rob
> 
> [1] http://lists.xen.org/archives/html/xen-devel/2013-10/msg00092.html

Thanks for your quick explanation Rob!
Willy

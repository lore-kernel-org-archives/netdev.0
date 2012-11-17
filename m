From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Fri, 16 Nov 2012 17:09:19 -0800
Message-ID: <1353114559.10798.66.camel@edumazet-glaptop>
References: <1353097030.2743.28.camel@bwh-desktop.uk.solarflarecom.com>
	 <1353106865.10798.61.camel@edumazet-glaptop>
	 <1353110430.2743.73.camel@bwh-desktop.uk.solarflarecom.com>
	 <1353111414.10798.64.camel@edumazet-glaptop>
	 <1353112324.2743.81.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Andrew Gallatin <gallatin@myri.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:61271 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753647Ab2KQBJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 20:09:21 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so1363021dak.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 17:09:21 -0800 (PST)
In-Reply-To: <1353112324.2743.81.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-11-17 at 00:32 +0000, Ben Hutchings wrote:
> On Fri, 2012-11-16 at 16:16 -0800, Eric Dumazet wrote:
> > On Sat, 2012-11-17 at 00:00 +0000, Ben Hutchings wrote:
> > 
> > > I'm not sure what you mean by this.  Is your point that the
> > > copy-on-write is never needed?  It is still possible for pskb_may_pull()
> > > to fail.
> > > 
> > 
> > A packet sniffer should have a copy of bad frames, even if dropped later
> > in our stacks.
> > 
> > GRO layer is not allowed to drop a frame, even if not 'correct'.
> 
> What do you think the accelerated hardware does with frames that have a
> truncated VLAN tag?

The hardware should send us the frame, exactly like when RX checksum is
wrong.

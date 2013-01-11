From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFCv2 00/12] Introduce host-side virtio queue and CAIF Virtio.
Date: Fri, 11 Jan 2013 09:31:55 +0200
Message-ID: <20130111073155.GA13315@redhat.com>
References: <871ug75vp1.fsf@rustcorp.com.au>
 <1354718230-4486-1-git-send-email-sjur@brendeland.net>
 <20121206102750.GF10837@redhat.com>
 <877goc0wac.fsf@rustcorp.com.au>
 <CAJK669bP41oBhJ=MB64NS21Ag7XO5WswuTiVKCFTb96nvmyBiw@mail.gmail.com>
 <87pq1f2rj0.fsf@rustcorp.com.au>
 <87wqvl1g9s.fsf@rustcorp.com.au>
 <20130110111117.GE13451@redhat.com>
 <87sj681wou.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sjur =?iso-8859-1?Q?Br=E6ndeland?= <sjurbren@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168Ab3AKH2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 02:28:09 -0500
Content-Disposition: inline
In-Reply-To: <87sj681wou.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 09:18:33AM +1030, Rusty Russell wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> > On Thu, Jan 10, 2013 at 09:00:55PM +1030, Rusty Russell wrote:
> >> Not sure why vhost/net doesn't built a packet and feed it in
> >> netif_rx_ni().  This is what tun seems to do, and with this code it
> >> should be fairly optimal.
> >
> > Because we want to use NAPI.
> 
> Not quite what I was asking; it was more a question of why we're using a
> raw socket, when we trivially have a complete skb already which we
> should be able to feed to Linux like any network packet.
> 
> And that path is pretty well optimized...
> 
> Cheers,
> Rusty.


Oh for some reason I thought you were talking about virtio.
I don't really understand what you are saying here - vhost
actually calls out to tun to build and submit the skb.

-- 
MST

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Wed, 15 Apr 2015 21:30:57 -0700
Message-ID: <1429158657.7346.160.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150416042005.GA12179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stefano.stabellini@eu.citrix.com, george.dunlap@eu.citrix.com,
	Jonathan.Davies@citrix.com, xen-devel@lists.xensource.com,
	wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, paul.durrant@citrix.com,
	christoffer.dall@linaro.org, felipe.franciosi@citrix.com,
	linux-arm-kernel@lists.infradead.org, david.vrabel@citrix.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34709 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbbDPEbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 00:31:00 -0400
In-Reply-To: <20150416042005.GA12179@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-16 at 12:20 +0800, Herbert Xu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > We already have netdev->gso_max_size and netdev->gso_max_segs
> > which are cached into sk->sk_gso_max_size & sk->sk_gso_max_segs
> 
> It is quite dangerous to attempt tricks like this because a
> tc redirection or netfilter nat could change the destination
> device rendering such hints incorrect.

Right but we are talking of performance hints, on quite basic VM setup.

Here the guest would use xen and this hint would apply.

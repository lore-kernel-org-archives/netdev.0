From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 3 Mar 2008 23:30:56 +0200
Message-ID: <84144f020803031330i2c0ea1f6kc5b02c8b26145797@mail.gmail.com>
References: <20080303093449.GA15091@wotan.suse.de>
	 <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com>
	 <20080303200613.GC8974@wotan.suse.de>
	 <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com>
	 <20080303201701.GF8974@wotan.suse.de>
	 <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Nick Piggin" <npiggin@suse.de>, netdev@vger.kernel.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, "David Miller" <davem@davemloft.net>,
	"Eric Dumazet" <dada1@cosmosbay.com>
To: "Christoph Lameter" <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:38351 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756334AbYCCVbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 16:31:01 -0500
Received: by wr-out-0506.google.com with SMTP id c49so441988wra.21
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 13:30:59 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 3 Mar 2008, Nick Piggin wrote:
> > > HWCACHE_ALIGN means that you want the object to be aligned at
> > > cacheline boundaries for optimization. Why does crossing cacheline
> > > boundaries matter in this case?
> >
> > No, HWCACHE_ALIGN means that you want the object not to cross cacheline
> > boundaries for at least cache_line_size() bytes. You invented new

On Mon, Mar 3, 2008 at 11:16 PM, Christoph Lameter <clameter@sgi.com> wrote:
>  Interesting new definition....

Well, not my definition either but SLAB has guaranteed that for small
objects in the past, so I think Nick has a point here. However, with
all this back and forth, I've lost track why this matters. I suppose
it causes regression on some workload?

                                Pekka

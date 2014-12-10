From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/6] net: Split netdev_alloc_frag into
 __alloc_page_frag and add __napi_alloc_frag
Date: Wed, 10 Dec 2014 09:13:00 -0800
Message-ID: <1418231580.27198.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
	 <20141210034042.2114.29360.stgit@ahduyck-vm-fedora20>
	 <1418227328.27198.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54887DB0.7040903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, ast@plumgrid.com, davem@davemloft.net,
	brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:57497 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755924AbaLJRNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 12:13:08 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so8031284igb.4
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 09:13:08 -0800 (PST)
In-Reply-To: <54887DB0.7040903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-10 at 09:06 -0800, Alexander Duyck wrote:

> That is an interesting idea.  I wonder if there would be a similar
> benefit for small packets.  If nothing else I might try a few
> experiments with ixgbe to see if I can take advantage of something similar.

I was planning to submit a core infrastructure when net-next reopens, a
simple layer to use instead of alloc_page(), and immediately usable in
Intel drivers.

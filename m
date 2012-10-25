From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tilegx: fix some issues in the SW TSO support
Date: Thu, 25 Oct 2012 18:51:53 +0100
Message-ID: <1351187513.2662.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <201210251737.q9PHbgev032681@farm-0012.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201210251737.q9PHbgev032681@farm-0012.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-10-25 at 13:25 -0400, Chris Metcalf wrote:
> This change correctly computes the header length and data length in
> the fragments to avoid a bug where we would end up with extremely
> slow performance.  Also adopt use of skb_frag_size() accessor.
[...]

By the way, since you're doing soft-TSO you should probably set
net_device::gso_max_segs, as explained in:

commit 30b678d844af3305cda5953467005cebb5d7b687
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Mon Jul 30 15:57:00 2012 +0000

    net: Allow driver to limit number of GSO segments per skb

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

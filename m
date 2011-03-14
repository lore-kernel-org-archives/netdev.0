From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: fcoe: correct checking for bonding
Date: Mon, 14 Mar 2011 15:53:35 -0500
Message-ID: <1300136015.31662.13.camel@mulgrave.site>
References: <20110312.105944.193725929.davem@davemloft.net>
	 <1300129447.19083.258.camel@fritz>
	 <20110314192201.GA2873@psychotron.redhat.com>
	 <20110314.132007.193707878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, robert.w.love@intel.com,
	linux-scsi@vger.kernel.org, devel@open-fcoe.org,
	netdev@vger.kernel.org, fubar@us.ibm.com, joe.eykholt@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:35924 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab1CNUxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 16:53:44 -0400
In-Reply-To: <20110314.132007.193707878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-14 at 13:20 -0700, David Miller wrote:
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Mon, 14 Mar 2011 20:22:02 +0100
> > Mon, Mar 14, 2011 at 08:04:07PM CET, robert.w.love@intel.com wrote:
> >>   Taking a patch like this through net{-next} could cause a merge
> >>problem at Linus' level if a later patch makes it though the normal
> >>process and conflicts. This is what I want to avoid.
> >>
> >>   This patch, although appreciated, isn't critical. I have collected it
> >>into my tree and will re-post it to scsi-misc. I see no reason to treat
> >>this patch differently from other patches.
> > 
> > Well I have another set of patches dependent on this one :(
> 
> True, also I think Rob is overreacting.
> 
> Any merge problems created will be handled properly by Linus.
> 
> I recently changed the interface to ipv4 and ipv6 route lookups, and
> this required all kinds of changes to stuff under Infiniband and elsewhere.
> It's the only sane way to handle this kind of thing.

What Rob means is that fcoe has been in pretty heavy flux and so
parallel patches can often cause non trivial merge nasties because of
code motion.  That said, I think we're pretty close to the end of the
patch series for the merge window and it's a simple patch, so as long as
it applies to net-next, I think we have an pretty low probability for
non trivial merges.  You can do it with my and Rob's acked-by.

James


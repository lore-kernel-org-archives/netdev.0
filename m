From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v2 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Wed, 13 May 2015 12:53:40 -0400
Message-ID: <20150513165339.GA3471@tuxdriver.com>
References: <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
 <1431377466-6676-1-git-send-email-linville@tuxdriver.com>
 <20150512.230628.1787617651802981793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jesse@nicira.com, azhou@nicira.com,
	stephen@networkplumber.org, alexander.h.duyck@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36511 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934143AbbEMRAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 13:00:17 -0400
Content-Disposition: inline
In-Reply-To: <20150512.230628.1787617651802981793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 11:06:28PM -0400, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 11 May 2015 16:51:06 -0400
> 
> > This is an initial implementation of a netdev driver for GENEVE
> > tunnels.  This implementation uses a fixed UDP port, and only supports
> > point-to-point links with specific partner endpoints.  Only IPv4
> > links are supported at this time.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > ---
> > Changes in v2:
> >  - removal of unneeded special lock for vni_list
> >  - removal of geneve_net_vni_add/del (replaced by open code)
> >  - break out of vni search loop in geneve_rx after match found
> >  - no longer deferring socket open at ndo_init(), now doing it in ndo_open()
> >  - check for non-multicast, non-zero remote link partner in newlink()
> >  - remove now unused workqueue stuff
> 
> John, could you please repost the full series when you make changes
> based upon feedback?  That helps me a lot.
> 
> Thanks!

Sure, no problem... :-)

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

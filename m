From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 1/3 v2] [E1000-devel] [rfc 1/4] igb: Add igb_cleanup_vf()
Date: Thu, 26 Nov 2009 10:26:16 +1100
Message-ID: <20091125232615.GM4794@verge.net.au>
References: <20091125063213.203372240@vergenet.net>
 <20091125063530.796967189@vergenet.net>
 <4B0DAF55.4060400@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Bergmann <arndbergmann@googlemail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53284 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759042AbZKYX0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:26:10 -0500
Content-Disposition: inline
In-Reply-To: <4B0DAF55.4060400@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2009 at 02:27:33PM -0800, Alexander Duyck wrote:
> Simon Horman wrote:
> >Move virtual finction cleanup code into igb_cleanup_vf() and for the sake
> >of symmetry rename igb_probe_vfs() as igb_init_vf().
> >
> >Although these functions aren't entirely symmetrical it should aid
> >maintenance by making the relationship between initialisation and cleanup
> >more obvious.
> >
> >Note that there appears to be no way for adapter->vfs_allocated_count to be
> >non-zero for the case where CONFIG_PCI_IOV is not set, so reseting this
> >value was moved to inside the relvant #ifdef.
> >
> >Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> The one thing I noticed with this patch is that it didn't remove the
> vf cleanup from igb_remove.  You may want to go back and also add
> the replacement of that function with igb_cleanup_vf to this patch.

Ooops, yes that would be a good idea.
I'll send a revised patch after testing it.


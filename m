From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] virtio: use __GFP_NOWARN for try_fill_recv in
 virtnet_poll
Date: Tue, 15 Feb 2011 11:25:50 +0100
Message-ID: <20110215102549.GD8341@tiehlicka.suse.cz>
References: <20110215093527.GB8341@tiehlicka.suse.cz>
 <201102152041.29179.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58777 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960Ab1BOKZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 05:25:51 -0500
Content-Disposition: inline
In-Reply-To: <201102152041.29179.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 15-02-11 20:41:29, Rusty Russell wrote:
> On Tue, 15 Feb 2011 08:05:27 pm Michal Hocko wrote:
> > Hi,
> > we have started seeing a lot of allocator messages complaining about
> > failed allocations from virtnet_poll in soft IRQ. Could you consider the
> > following patch, please?
> 
> Do we really want to silence this?  Isn't warning about it kind of the
> point?  Your network is probably sucking if this happens...

What can user do about it? Is the low level memory allocator message
very much usefull for him?  Maybe we can add a printk_once in the fail
path with some more useful and virtio specific message.

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

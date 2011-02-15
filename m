From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] virtio: use __GFP_NOWARN for try_fill_recv in
 virtnet_poll
Date: Tue, 15 Feb 2011 13:39:36 +0100
Message-ID: <20110215123936.GE8341@tiehlicka.suse.cz>
References: <20110215093527.GB8341@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:36913 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754624Ab1BOMji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 07:39:38 -0500
Content-Disposition: inline
In-Reply-To: <20110215093527.GB8341@tiehlicka.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 15-02-11 10:35:27, Michal Hocko wrote:
[...]
> [22798.508903] The following is only an harmless informational message.
> [22798.508909] Unless you get a _continuous_flood_ of these messages it means
> [22798.508911] everything is working fine. Allocations from irqs cannot be
> [22798.508913] perfectly reliable and the kernel is designed to handle that.

I have just realized that the above text is SLES specific so only the
line below with stack trace and memory info is printed. Sorry for confusion

> [22798.508917] loop3: page allocation failure. order:0, mode:0x20, alloc_flags:0x30 pflags:0x80208040

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

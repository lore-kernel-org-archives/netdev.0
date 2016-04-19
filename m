From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v2 2/4] io-mapping: Specify mapping size for
 io_mapping_map_wc()
Date: Tue, 19 Apr 2016 14:30:28 +0200
Message-ID: <20160419123028.GI1990@wotan.suse.de>
References: <1460978042-9953-1-git-send-email-chris@chris-wilson.co.uk>
 <1460978042-9953-2-git-send-email-chris@chris-wilson.co.uk>
 <20160419120225.GF26039@nuc-i3427.alporthouse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chris Wilson <chris@chris-wilson.co.uk>,
	intel-gfx@lists.freedesktop.org,
	Tvrtko Ursulin <tvrtko.ursulin@intel.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	David Airlie <airlied@linux.ie>,
	Yishai Hadas <yishaih@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ingo Molnar <mingo@kernel.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	David Hildenbrand <dahi@linux.vnet.ibm.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48754 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753891AbcDSMak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 08:30:40 -0400
Content-Disposition: inline
In-Reply-To: <20160419120225.GF26039@nuc-i3427.alporthouse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 01:02:25PM +0100, Chris Wilson wrote:
> On Mon, Apr 18, 2016 at 12:14:00PM +0100, Chris Wilson wrote:
> > The ioremap() hidden behind the io_mapping_map_wc() convenience helper
> > can be used for remapping multiple pages. Extend the helper so that
> > future callers can use it for larger ranges.
> 
> Adding Luis Rodriguez as he has been active in the area of ioremap_*().

Can someone bounce me a copy of the original e-mails? Can you also use
mcgrof@kernel.org ?

  Luis

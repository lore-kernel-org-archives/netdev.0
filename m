From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/27] Add support for DMA writable pages
 being writable by the network stack
Date: Fri, 28 Oct 2016 13:06:57 -0400 (EDT)
Message-ID: <20161028.130657.1245186418157500995.davem@davemloft.net>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
	<CAKgT0UfOZuRnon84_8Bdn5muoi7=Xrwd7Kbxi4C8jiXpyX7-gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com,
 alexander.h.duyck@intel.com, konrad.wilk@oracle.com,
 jeffrey.t.kirsher@intel.com
To: alexander.duyck@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAKgT0UfOZuRnon84_8Bdn5muoi7=Xrwd7Kbxi4C8jiXpyX7-gg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 28 Oct 2016 08:48:01 -0700

> So the feedback for this set has been mostly just a few "Acked-by"s,
> and it looks like the series was marked as "Not Applicable" in
> patchwork.  I was wondering what the correct merge strategy for this
> patch set should be going forward?

I marked it as not applicable because it's definitely not a networking
change, and merging it via my tree would be really inappropriate, even
though we need it for some infrastructure we want to build for
networking.

So you have to merge this upstream via a more appropriate path.

> I was wondering if I should be looking at breaking up the set and
> splitting it over a few different trees, or if I should just hold onto
> it and resubmit it when the merge window opens?  My preference would
> be to submit it as a single set so I can know all the patches are
> present to avoid any possible regressions due to only part of the set
> being present.

I don't think you need to split it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

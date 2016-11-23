From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH ethtool v4 1/2] ethtool-copy.h:sync with net
Date: Wed, 23 Nov 2016 10:55:07 -0500
Message-ID: <20161123155506.GD13179@tuxdriver.com>
References: <1479846737-18669-1-git-send-email-allan.nielsen@microsemi.com>
 <1479846737-18669-2-git-send-email-allan.nielsen@microsemi.com>
 <20161123152447.GC13179@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44528 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938788AbcKWQAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 11:00:47 -0500
Content-Disposition: inline
In-Reply-To: <20161123152447.GC13179@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 10:24:47AM -0500, John W. Linville wrote:
> It looks like this patch somehow misses the following commit:
> 
> commit 85a624403c77c3f074931aefdfced59f61b668cb
> Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date:   Thu Oct 13 16:13:55 2016 -0700
> 
>     ethtool: silence warning on bit loss
>     
>     Sparse was complaining when we went to prototype some code
>     using ethtool_cmd_speed_set and SPEED_100000, which uses
>     the upper 16 bits of __u32 speed for the first time.
>     
>     CHECK
>     ...
>     .../uapi/linux/ethtool.h:123:28: warning:
>       cast truncates bits from constant value (186a0 becomes 86a0)
>     
>     The warning is actually bogus, as no bits are really lost, but
>     we can get rid of the sparse warning with this one small change.
>     
>     Reported-by: Preethi Banala <preethi.banala@intel.com>
>     Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Plus, the referenced commit does not seem to exist in the net-next tree.
> 
> Please resubmit with the complete history and correct commit IDs -- thanks!

I mean, of course, all the preceding changes accounted for -- not
every commit explicitly listed. The top commit does, of course,
need to reflect the correct commit ID from Dave's/Linus's tree.
 
John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

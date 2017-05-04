From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH RESEND 4.4-only] netlink: Allow direct reclaim for
 fallback allocation
Date: Thu, 4 May 2017 12:38:14 -0700
Message-ID: <20170504193814.GB10166@kroah.com>
References: <1493801059-2828-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Ross Lagerwall <ross.lagerwall@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1493801059-2828-1-git-send-email-ross.lagerwall@citrix.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2017 at 09:44:19AM +0100, Ross Lagerwall wrote:
> The backport of d35c99ff77ec ("netlink: do not enter direct reclaim from
> netlink_dump()") to the 4.4 branch (first in 4.4.32) mistakenly removed
> direct claim from the initial large allocation _and_ the fallback
> allocation which means that allocations can spuriously fail.
> Fix the issue by adding back the direct reclaim flag to the fallback
> allocation.
> 
> Fixes: 6d123f1d396b ("netlink: do not enter direct reclaim from netlink_dump()")
> Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
> ---
> 
> Note that this is only for the 4.4 branch as the regression is only in
> this branch. Consequently, there is no corresponding upstream commit.
> 
> I'm resending this to the linux-stable list since I now understand the
> netdev maintainer only handles backports for the last couple of versions
> of Linux.
> 

Many thanks for this fix, now queued up.

greg k-h

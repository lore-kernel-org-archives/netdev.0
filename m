From: Greg KH <greg@kroah.com>
Subject: Re: xen-netback stable backports request (regression fixes)
Date: Tue, 4 Jun 2013 21:55:32 -0700
Message-ID: <20130605045532.GA10475@kroah.com>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 28, 2013 at 10:47:45AM +0100, Ian Campbell wrote:
> Hi Dave, stable folks,
> 
> The following set of patches fix a xen netback regression caused by the
> fixes for CVE-2013-0216 / CVE-2013-0217 / XSA-39 (the original change
> was several patches starting at 48856286b64e), we'd like to see them
> backported to stable branches if possible. I think the fixups have now
> been in Linus tree since around the start of May.
> 
> Wei and I are happy to help with backports if necessary. Some of the
> patches are cleanups which make backports easier but if you would prefer
> we could produce backports without them.
> 
> 27f85228 xen-netback: remove skb in xen_netbk_alloc_page

I've applied this one.

> 2810e5b9 xen-netback: coalesce slots in TX path and fix regressions

This patch does not apply cleanly to 3.9-stable.  So I can't apply
anything else.  Can you please provide backports?

> 03393fd5 xen-netback: don't disconnect frontend when seeing oversize packet
> ac69c26e xen-netback: remove redundent parameter in netbk_count_requests
> 59ccb4eb xen-netback: avoid allocating variable size array on stack
> 37641494 xen-netback: better names for thresholds

Why are these last two patches needed for a stable tree?

> In addition there are some useful related (but not security relevant)
> fixes to netfront:
> 
> e2d617c0 xen-netfront: remove unused variable `extra'
> 7158ff6d xen-netfront: frags -> slots in xennet_get_responses
> 697089dc xen-netfront: frags -> slots in log message
> 9ecd1a75 xen-netfront: reduce gso_max_size to account for max TCP header

Why are they needed for stable releases?  What do they fix?

greg k-h

From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V6] Bundle fixes for Xen netfront / netback
Date: Wed, 17 Apr 2013 19:17:40 +0100
Message-ID: <20130417181740.GF5815@zion.uk.xensource.com>
References: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
 <20130417.140900.40803700259873477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:48839 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965837Ab3DQSRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 14:17:41 -0400
Content-Disposition: inline
In-Reply-To: <20130417.140900.40803700259873477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 07:09:00PM +0100, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Wed, 17 Apr 2013 18:41:59 +0100
> 
> > Final round of this series. All acked and ready to go in.
> 
> Does not apply to net-next.
> 
> [davem@drr net-next]$ git am --signoff bundle-4170-xen.mbox 
> Applying: xen-netfront: frags -> slots in log message
> Applying: xen-netfront: reduce gso_max_size to account for max TCP header
> Applying: xen-netback: coalesce slots in TX path and fix regressions
> error: patch failed: drivers/net/xen-netback/netback.c:1548
> error: drivers/net/xen-netback/netback.c: patch does not apply
> Patch failed at 0003 xen-netback: coalesce slots in TX path and fix regressions
> The copy of the patch that failed is found in:
>    /home/davem/src/GIT/net-next/.git/rebase-apply/patch
> When you have resolved this problem run "git am --resolved".
> If you would prefer to skip this patch, instead run "git am --skip".
> To restore the original branch and stop patching run "git am --abort".
> 
> Please stop wasting my time.

Sorry Dave, I didn't mean to waste your time. I will rebase my patches
and post the really final series.


Wei.

From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 4/7] xen-netfront: frags -> slots in log message
Date: Fri, 12 Apr 2013 15:58:29 +0100
Message-ID: <20130412145829.GA17602@zion.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-5-git-send-email-wei.liu2@citrix.com>
 <5164190D.70905@cogentembedded.com>
 <20130409134745.GI16998@zion.uk.xensource.com>
 <51681CC6.7070408@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32657 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3DLO64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 10:58:56 -0400
Content-Disposition: inline
In-Reply-To: <51681CC6.7070408@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 03:40:06PM +0100, Sergei Shtylyov wrote:
> Hello.
> 
> On 09-04-2013 17:47, Wei Liu wrote:
> 
> >>> Also fix a typo in comment.
> 
> >>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> >>> ---
> >>>    drivers/net/xen-netfront.c |    4 ++--
> >>>    1 file changed, 2 insertions(+), 2 deletions(-)
> 
> >>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> >>> index d9097a7..1bb2e20 100644
> >>> --- a/drivers/net/xen-netfront.c
> >>> +++ b/drivers/net/xen-netfront.c
> >> [...]
> >>> @@ -771,7 +771,7 @@ next:
> >>>
> >>>    	if (unlikely(slots > max)) {
> >>>    		if (net_ratelimit())
> >>> -			dev_warn(dev, "Too many frags\n");
> >>> +			dev_warn(dev, "Too many slots\n");
> >>
> >>      Shouldn't you have done this change as a part of patch #2?
> 
> > Because patch 2 has been applied to David Miller's tree, this is an
> > incremental patch on top of that.
> 
>     Why are you reposting already applied patch over and over again then?
> 

Just for completeness. I stated that in email 0.

Some people might be interested in applying the whole series to their
local tree instead of cherry-picking from DaveM's tree.


Wei.

> > Wei.
> 
> WBR, Sergei

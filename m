From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Subject: Re: [PATCH] rds: rds-stress show all zeros after few minutes
Date: Thu, 31 Mar 2016 17:25:48 +0300
Message-ID: <20160331142547.GB24193@shamir-linux.uk.oracle.com>
References: <1459385402-28449-1-git-send-email-shamir.rabinovitch@oracle.com>
 <56FD227F.502@cogentembedded.com>
 <20160331142047.GA24193@shamir-linux.uk.oracle.com>
 <56FD32E2.8050003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40719 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756948AbcCaOZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 10:25:55 -0400
Content-Disposition: inline
In-Reply-To: <56FD32E2.8050003@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 05:23:30PM +0300, Sergei Shtylyov wrote:
> On 3/31/2016 5:20 PM, Shamir Rabinovitch wrote:
> 
> >>>Issue can be seen on platforms that use 8K and above page size
> >>>while rds fragment size is 4K. On those platforms single page is
> >>>shared between 2 or more rds fragments. Each fragment has it's own
> >>
> >>    Its.
> >
> >Fixed in next version.
> >Thanks.
> >
> >>
> >>>offeset and rds cong map code need to take this offset to account.
> >>
> >>    Offset. What is "cong", congestion?
> >
> >'Offset' is in middle of the sentence so it is OK as-is.
> 
>    No, "offeset" is not OK. :-)

Oh. Typo. Sorry. Will fix! :-)

> 
> [...]
> 
> >>>Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> [...]
> 
> MBR, Sergei
> 

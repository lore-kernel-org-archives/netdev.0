From: "Karen Xie" <kxie@chelsio.com>
Subject: RE: [PATCH] cxgbi: bug fixes and code cleanup
Date: Wed, 22 Sep 2010 13:52:07 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334086AC20E@maui.asicdesigners.com>
References: <201009211609.o8LG9HPm014568@localhost.localdomain> <4C9A627D.4060800@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<open-iscsi@googlegroups.com>,
	"Rakesh Ranjan" <rakesh@chelsio.com>,
	<James.Bottomley@HansenPartnership.com>, <davem@davemloft.net>
To: "Mike Christie" <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27080 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829Ab0IVUxI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:53:08 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Mike.
I will fix the patch and break it into per change.
Karen

-----Original Message-----
From: Mike Christie [mailto:michaelc@cs.wisc.edu] 
Sent: Wednesday, September 22, 2010 1:10 PM
To: Karen Xie
Cc: netdev@vger.kernel.org; linux-scsi@vger.kernel.org;
open-iscsi@googlegroups.com; Rakesh Ranjan;
James.Bottomley@HansenPartnership.com; davem@davemloft.net
Subject: Re: [PATCH] cxgbi: bug fixes and code cleanup

On 09/21/2010 11:09 AM, kxie@chelsio.com wrote:
> [PATCH] cxgbi: bug fixes and code cleanup
>
> From: Karen Xie<kxie@chelsio.com>
>
> The patch includes the following changes.
> - removed un-used code
> - renamed alloc_cpl() to alloc_wr().
> - fixed connecting over VLAN.
> - updated cxgb4i connection setting and pagepod programming.

Could you break up the patch into a patch per change next time?


> -				read_lock(&csk->callback_lock);
>   				dskb = skb_peek(&csk->receive_queue);
>   				if (!dskb) {
>
read_unlock(&csk->callback_lock);

I think you also have to remove this read_unlock call.

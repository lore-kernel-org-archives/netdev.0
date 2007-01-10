From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] [SCTP]: Fix err_hdr assignment in sctp_init_cause.
Date: Wed, 10 Jan 2007 11:29:24 -0800
Message-ID: <1168457364.8248.6.camel@w-sridhar2.beaverton.ibm.com>
References: <1168370809.24896.20.camel@w-sridhar2.beaverton.ibm.com>
	 <20070109.143628.104034780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:52508 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965033AbXAJT3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 14:29:35 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0AJTTG0020251
	for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 14:29:29 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l0AJTTY4299946
	for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 14:29:29 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0AJTS6X006091
	for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 14:29:28 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20070109.143628.104034780.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-09 at 14:36 -0800, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Tue, 09 Jan 2007 11:26:49 -0800
> 
> > [SCTP]: Fix err_hdr assignment in sctp_init_cause.
> >
> > The subh->err_hdr should point to the error header, not the data.
> >
> > Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Applied, thanks Sridahr.
> 
> Do we need this for the 2.6.x -stable branches too?

This bug was found during code review and is not critical
as err_hdr is not really used in the send path currently,
although this may change in future.

So we don't need this for -stable branches.

Thanks
Sridhar




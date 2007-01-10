From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP]: Fix err_hdr assignment in sctp_init_cause.
Date: Wed, 10 Jan 2007 12:58:06 -0800 (PST)
Message-ID: <20070110.125806.106267729.davem@davemloft.net>
References: <1168370809.24896.20.camel@w-sridhar2.beaverton.ibm.com>
	<20070109.143628.104034780.davem@davemloft.net>
	<1168457364.8248.6.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965084AbXAJU6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 15:58:08 -0500
To: sri@us.ibm.com
In-Reply-To: <1168457364.8248.6.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 10 Jan 2007 11:29:24 -0800

> On Tue, 2007-01-09 at 14:36 -0800, David Miller wrote:
> > From: Sridhar Samudrala <sri@us.ibm.com>
> > Date: Tue, 09 Jan 2007 11:26:49 -0800
> > 
> > > [SCTP]: Fix err_hdr assignment in sctp_init_cause.
> > >
> > > The subh->err_hdr should point to the error header, not the data.
> > >
> > > Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> > > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > 
> > Applied, thanks Sridahr.
> > 
> > Do we need this for the 2.6.x -stable branches too?
> 
> This bug was found during code review and is not critical
> as err_hdr is not really used in the send path currently,
> although this may change in future.
> 
> So we don't need this for -stable branches.

Ok, thanks for the info.

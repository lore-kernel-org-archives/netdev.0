From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [SCTP]: Verify some mandatory parameters.
Date: Tue, 23 Jan 2007 22:32:44 -0800 (PST)
Message-ID: <20070123.223244.111204497.davem@davemloft.net>
References: <1168544487.22592.19.camel@w-sridhar2.beaverton.ibm.com>
	<45AE857D.8000208@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932954AbXAXGcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:32:50 -0500
In-Reply-To: <45AE857D.8000208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 17 Jan 2007 15:22:21 -0500

> > --- a/net/sctp/sm_statefuns.c
> > +++ b/net/sctp/sm_statefuns.c
> > @@ -462,24 +461,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
> 
> > -	if (!init_tag) {
> > -		struct sctp_chunk *reply = sctp_make_abort(asoc, chunk, 0);
> > -		if (!reply)
> > -			goto nomem;
> 
> This introduced a compiler warning, easily fixed.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, thanks a lot Brian.

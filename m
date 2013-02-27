From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Wed, 27 Feb 2013 07:35:30 -0500
Message-ID: <20130227123530.GA17205@neilslaptop.think-freely.org>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <20130226.173758.1729388485427908984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lee.roberts@hp.com, netdev@vger.kernel.org, vyasevich@gmail.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50082 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583Ab3B0Mfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 07:35:48 -0500
Content-Disposition: inline
In-Reply-To: <20130226.173758.1729388485427908984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2013 at 05:37:58PM -0500, David Miller wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
> Date: Tue, 26 Feb 2013 07:36:12 -0700
> 
> > This series of patches resolves several SCTP association hangs observed during
> > SCTP stress testing.  Observable symptoms include communications hangs with
> > data being held in the association reassembly and/or lobby (ordering) queues.
> > Close examination of reassembly/ordering queues may show either duplicated
> > or missing packets.
> > 
> > Lee A. Roberts (4):
> >   sctp: fix association hangs due to off-by-one errors in
> >     sctp_tsnmap_grow()
> >   sctp: fix association hangs due to reneging packets below the
> >     cumulative TSN ACK point
> >   sctp: fix association hangs due to errors when reneging events from
> >     the ordering queue
> >   sctp: fix association hangs due to partial delivery errors
> 
> Vlad, Sridhar, and Neil, please review.
> 
IIRC, Vlad already/still has some outstanding comments & questions regarding
this series.
Neil

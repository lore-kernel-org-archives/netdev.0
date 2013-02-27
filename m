From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Wed, 27 Feb 2013 12:15:27 -0500
Message-ID: <20130227171527.GA7993@hmsreliant.think-freely.org>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <20130226.173758.1729388485427908984.davem@davemloft.net>
 <512E373D.9020301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, lee.roberts@hp.com,
	netdev@vger.kernel.org, vyasevich@gmail.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53787 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab3B0RQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 12:16:00 -0500
Content-Disposition: inline
In-Reply-To: <512E373D.9020301@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 08:41:33AM -0800, Sridhar Samudrala wrote:
> On 2/26/2013 2:37 PM, David Miller wrote:
> >From: "Lee A. Roberts" <lee.roberts@hp.com>
> >Date: Tue, 26 Feb 2013 07:36:12 -0700
> >
> >>This series of patches resolves several SCTP association hangs observed during
> >>SCTP stress testing.  Observable symptoms include communications hangs with
> >>data being held in the association reassembly and/or lobby (ordering) queues.
> >>Close examination of reassembly/ordering queues may show either duplicated
> >>or missing packets.
> >>
> >>Lee A. Roberts (4):
> >>   sctp: fix association hangs due to off-by-one errors in
> >>     sctp_tsnmap_grow()
> >>   sctp: fix association hangs due to reneging packets below the
> >>     cumulative TSN ACK point
> >>   sctp: fix association hangs due to errors when reneging events from
> >>     the ordering queue
> >>   sctp: fix association hangs due to partial delivery errors
> >Vlad, Sridhar, and Neil, please review.
> 
> I am no longer able to spend time on reviewing SCTP patches.
> Please remove my name from the maintainers list. Should i submit a patch ?
> 
> Thanks
> Sridhar
> 
> 
Yes, please. 

Thanks!
Neil

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: bna alloc_pages() order 2 failure in bnad.c
 bnad_rxq_refill_page()
Date: Tue, 30 Sep 2014 05:23:30 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>
 <20140929092833.6c2cb7e9@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"rmody@brocade.com" <rmody@brocade.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Wheeler <nevdev@lists.ewheeler.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:44187 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbaI3FXf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 01:23:35 -0400
In-Reply-To: <20140929092833.6c2cb7e9@urahara>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+Rasesh, Maintainer of bna driver.

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> Sent: Monday, September 29, 2014 9:59 PM
> To: Eric Wheeler
> Cc: netdev; rmody@brocade.com
> Subject: Re: bna alloc_pages() order 2 failure in bnad.c
> bnad_rxq_refill_page()
>
> On Sat, 27 Sep 2014 16:44:22 -0700 (PDT) Eric Wheeler
> <nevdev@lists.ewheeler.net> wrote:
>
> > Hello all,
> >
> > We're using the 10gbe bna card and sometimes we get pages and pages of
> > alloc_pages() failure backtraces like below.  (The maintainer
> > rmody@brocade.com does not appear to have an active email at brocade,
> > but cc'ing again just in case.)
> >
> > It looks like bnad_rxq_refill_page() in bnad.c is allocating for the
> > receive queue but fails.  We've already tried bumping
> > vm.min_free_kbytes and vm.zone_reclaim_mode but it doesn't appear to
> help.
> >
> > Suggestions?
> >
> > Would it be appropriate to convert alloc_pages() to a mempool
> > implementation?
> >
> > -Eric
>
> Brocade sold the NIC hardware business off to Qlogic.
> I told them to update MAINTAINERS but they haven't submitted a patch yet.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

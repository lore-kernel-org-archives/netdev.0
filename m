From: Matt Wilson <msw@linux.com>
Subject: Re: xen-netback: count number required slots for an skb more
 carefully
Date: Tue, 3 Sep 2013 23:04:55 -0700
Message-ID: <20130904060446.GA25227@u109add4315675089e695.ant.amazon.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com>
 <20130903215328.GA13465@zion.uk.xensource.com>
 <52269A37.7030600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	xen-devel@lists.xen.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	msw@amazon.com
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:61612 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761388Ab3IDGFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 02:05:03 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so6956040pdj.8
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 23:05:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <52269A37.7030600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 10:25:59AM +0800, annie li wrote:
> On 2013-9-4 5:53, Wei Liu wrote:
[...]
> >Matt, do you fancy sending the final version? IIRC the commit message
> >needs to be re-written. I personally still prefer Matt's solution as
> >it a) make efficient use of the ring, b) uses ring pointers to
> >calculate slots which is most accurate, c) removes the dependence on
> >MAX_SKB_FRAGS in guest RX path.
> >
> >Anyway, we should get this fixed ASAP.
> 
> Totally agree. This issue is easy to be reproduced with large MTU.
> It is better to upstream the fix soon in case others hit it and
> waste time to fix it.

I'd like to go with Xi's proposed patch that I posed earlier. The main
thing that's kept me from sending a final version is lack of time to
retest against a newer kernel.

Could someone help out with that? I probably can't get to it until the
end of the week.

Sorry for the delay. :-(

--msw

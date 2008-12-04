From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 04/39] wimax: internal API for the kernel space WiMAX stack
Date: Thu, 4 Dec 2008 11:22:13 -0800
Message-ID: <200812041122.13320.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <200812021807.38335.inaky@linux.intel.com> <1228381356.3197.19.camel@Friederike-PC.hoffi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:30437 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753922AbYLDTav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 14:30:51 -0500
In-Reply-To: <1228381356.3197.19.camel@Friederike-PC.hoffi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 December 2008, Johannes Berg wrote:
> On Tue, 2008-12-02 at 18:07 -0800, Inaky Perez-Gonzalez wrote:
> > > > +static inline __must_check
> > > > +int wimax_dev_is_ready(struct wimax_dev *wimax_dev)
> > > > +{
> > > > +	if (wimax_dev->state == __WIMAX_ST_NULL)
> > > > +		return -EINVAL;	/* Device is not even registered! */
> > > > +	if (wimax_dev->state == WIMAX_ST_DOWN)
> > > > +		return -ENOMEDIUM;
> > >
> > > ENOLINK seems more appropriate?
> >
> > Well, this means there is no medium on which to try to establish a
> > link. It doesn't really matter.
> >
> > Is it used mainly for storage applications?
>
> Yes, I think so.

Ack, I'll switch it to -ENOLINK.

Thanks,

-- 
Inaky

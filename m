From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 04/39] wimax: internal API for the kernel space WiMAX stack
Date: Tue, 2 Dec 2008 18:07:38 -0800
Message-ID: <200812021807.38335.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <960be5a67120268108e2b252921161762fac9aeb.1227691434.git.inaky@linux.intel.com> <1227778999.3809.34.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:39507 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753640AbYLCCLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:31 -0500
In-Reply-To: <1227778999.3809.34.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:


> > +static inline __must_check
> > +int wimax_dev_is_ready(struct wimax_dev *wimax_dev)
> > +{
> > +	if (wimax_dev->state == __WIMAX_ST_NULL)
> > +		return -EINVAL;	/* Device is not even registered! */
> > +	if (wimax_dev->state == WIMAX_ST_DOWN)
> > +		return -ENOMEDIUM;
>
> ENOLINK seems more appropriate?

Well, this means there is no medium on which to try to establish a
link. It doesn't really matter.

Is it used mainly for storage applications?

> > +/*
> > + * The concept of a pipe -- we encapsulate it because we want to
> > + * detach the usage of it from the implementation, and thus it serves
> > + * just as a handle.
>
> Might help to explain just what the concept is :)

Yes, that required some documentation fixes; added, thanks.


-- 
Inaky


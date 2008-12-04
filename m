From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 04/39] wimax: internal API for the kernel space WiMAX
	stack
Date: Thu, 04 Dec 2008 10:02:36 +0100
Message-ID: <1228381356.3197.19.camel@Friederike-PC.hoffi>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <960be5a67120268108e2b252921161762fac9aeb.1227691434.git.inaky@linux.intel.com>
	 <1227778999.3809.34.camel@johannes.berg>
	 <200812021807.38335.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:42951 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080AbYLDJDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 04:03:21 -0500
In-Reply-To: <200812021807.38335.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-02 at 18:07 -0800, Inaky Perez-Gonzalez wrote:

> > > +static inline __must_check
> > > +int wimax_dev_is_ready(struct wimax_dev *wimax_dev)
> > > +{
> > > +	if (wimax_dev->state == __WIMAX_ST_NULL)
> > > +		return -EINVAL;	/* Device is not even registered! */
> > > +	if (wimax_dev->state == WIMAX_ST_DOWN)
> > > +		return -ENOMEDIUM;
> >
> > ENOLINK seems more appropriate?
> 
> Well, this means there is no medium on which to try to establish a
> link. It doesn't really matter.
> 
> Is it used mainly for storage applications?

Yes, I think so.

johannes


From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 11/39] wimax: RF-kill framework integration
Date: Tue, 2 Dec 2008 18:03:50 -0800
Message-ID: <200812021803.51169.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <3db0d6b9524acff7af098c46dfc9dc8d4f17acba.1227691434.git.inaky@linux.intel.com> <1227779780.3809.45.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:2473 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753919AbYLCCLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:31 -0500
In-Reply-To: <1227779780.3809.45.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> > +struct genl_ops wimax_gnl_rfkill = {
> > +	.cmd = WIMAX_GNL_OP_RFKILL,
> > +	.flags = 0,
>
> permissions thing again

Fixed

> Also, doesn't rfkill already have a userspace interface in sysfs? Why
> add another one?

Need it to query also the hardware rfkill state, which wasn't available
on rfkill's interface. This uses almost the same mechanism, in any case.

-- 
Inaky


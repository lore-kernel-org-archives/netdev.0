From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 08/39] wimax: Mappping of generic netlink family IDs to net devices
Date: Tue, 2 Dec 2008 18:06:39 -0800
Message-ID: <200812021806.39847.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <6ffe4147aad336132ea57ae1bd950690d84fabbf.1227691434.git.inaky@linux.intel.com> <1227779241.3809.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:5961 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752812AbYLCCL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:28 -0500
In-Reply-To: <1227779241.3809.36.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> > +		}
> > +	}
> > +	d_printf(1, NULL, "wimax: no device associated to ID %d\n", id);
>
> remove debug statement (or make it depend on !wimax_dev)
>
> > +	wimax_dev = NULL;
> > +out_unlock:
> > +	spin_unlock(&wimax_id_table_lock);
> > +	d_fnend(3, NULL, "(info %p) = %p\n", info, wimax_dev);
> > +	return wimax_dev;
>
> No need for gotos any more :)

Duh ... sometimes the autopilot is not a good thing.

Fixed, thanks

-- 
Inaky


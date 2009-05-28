From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [patch 2.6.31 08/10] wimax: Add netlink interface to get device state
Date: Thu, 28 May 2009 09:16:21 -0700
Message-ID: <200905280916.23022.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com> <4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com> <20090527182157.48a3f4b0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32708 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374AbZE1QRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2009 12:17:22 -0400
In-Reply-To: <20090527182157.48a3f4b0@nehalam>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 May 2009, Stephen Hemminger wrote:
> On Wed, 27 May 2009 18:05:13 -0700
>
> Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:
> > From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> >
> > wimax connection manager / daemon has to know what is current
> > state of the device. Previously it was only possible to get
> > notification whet state has changed.
> >
> > ...
> > ...
> > > > diff --git a/include/linux/wimax.h b/include/linux/wimax.h 
> > index c89de7f..c750f42 100644
> > --- a/include/linux/wimax.h
> > +++ b/include/linux/wimax.h
> > @@ -77,6 +77,7 @@ enum {
> >  	WIMAX_GNL_OP_MSG_TO_USER,	/* Kernel to user message */
> >  	WIMAX_GNL_OP_RFKILL,	/* Run wimax_rfkill() */
> >  	WIMAX_GNL_OP_RESET,	/* Run wimax_rfkill() */
> > +	WIMAX_GNL_OP_STATE_GET,		/* Request for current state */
> >  	WIMAX_GNL_RE_STATE_CHANGE,	/* Report: status change */
> >  };
>
> Won't adding new element in middle of list break existing ABI?

Actually that's an extremely good point that I missed completely. 
Thanks for catching it.

David, I'll submit an extra commit for correcting that point.


-- 
Inaky

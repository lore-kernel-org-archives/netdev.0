From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] Added additional callback to ptp_clock_info:
Date: Wed, 8 Jul 2015 13:54:34 +0200
Message-ID: <20150708115434.GA17012@localhost.localdomain>
References: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
 <1435886088-13890-2-git-send-email-christopher.s.hall@intel.com>
 <20150706204458.GE25028@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christopher Hall <christopher.s.hall@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: Josh Cartwright <joshc@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33605 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932745AbbGHLyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 07:54:40 -0400
Content-Disposition: inline
In-Reply-To: <20150706204458.GE25028@jcartwri.amer.corp.natinst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2015 at 03:44:58PM -0500, Josh Cartwright wrote:
> It's difficult to make too many judgements without seeing how a driver
> might implement this; is there another patchset that shows how a driver
> implements this?

The interface is certainly clear enough to me.  The details of
obtaining a cross time stamp from the hardware will remain hidden
behind the interface in any case.

> > -	int rsv[14];   /* Reserved for future use. */
> > +	/* Whether the clock supports precise system-device cross timestamps */
> > +	int precise_timestamping;
> 
> Perhaps now is a good time to add an unsigned int 'flags' member instead,
> and start allocating bits.

Considering the rate of growth for the PHC stuff, I am not worried
about spending a whole 'int' on this.

Thanks,
Richard

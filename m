From: Rodolfo Giometti <giometti@enneenne.com>
Subject: Re: [PATCH net-next 01/11] pps/ptp: Allow PHC devices to adjust
	PPS events for known delay
Date: Thu, 20 Sep 2012 09:29:54 +0200
Message-ID: <20120920072954.GA6531@gundam.enneenne.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com> <1348082024.2636.16.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Richard Cochran <richardcochran@gmail.com>,
	Andrew Jackson <ajackson@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-196-116.sn1.eutelia.it ([62.94.196.116]:15741 "EHLO
	goldrake.enneenne.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751260Ab2ITIGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 04:06:44 -0400
Content-Disposition: inline
In-Reply-To: <1348082024.2636.16.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 19, 2012 at 08:13:44PM +0100, Ben Hutchings wrote:
> Initial version by Stuart Hodgson <smhodgson@solarflare.com>
> 
> Some PHC device drivers may deliver PPS events with a significant
> and variable delay, but still be able to measure precisely what
> that delay is.
> 
> Add a pps_sub_ts() function for subtracting a delay from the
> timestamp(s) in a PPS event, and a PTP event type (PTP_CLOCK_PPSUSR)
> for which the caller provides a complete PPS event.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: Rodolfo Giometti <giometti@enneenne.com>

-- 

GNU/Linux Solutions                  e-mail: giometti@enneenne.com
Linux Device Driver                          giometti@linux.it
Embedded Systems                     phone:  +39 349 2432127
UNIX programming                     skype:  rodolfo.giometti
Freelance ICT Italia - Consulente ICT Italia - www.consulenti-ict.it

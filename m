From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 01/11] pps/ptp: Allow PHC devices to adjust
 PPS events for known delay
Date: Thu, 20 Sep 2012 08:57:26 +0200
Message-ID: <20120920065725.GA2349@netboy.at.omicron.at>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
 <1348082024.2636.16.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Rodolfo Giometti <giometti@enneenne.com>,
	Andrew Jackson <ajackson@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:33593 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab2ITG5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 02:57:35 -0400
Received: by wgbfm10 with SMTP id fm10so183276wgb.1
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 23:57:34 -0700 (PDT)
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

Acked-by: Richard Cochran <richardcochran@gmail.com>

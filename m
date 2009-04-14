From: Robin Holt <holt@sgi.com>
Subject: Re: SEEPROM test patch
Date: Tue, 14 Apr 2009 13:22:39 -0500
Message-ID: <20090414182239.GM10768@sgi.com>
References: <20090414172123.GA12319@xw6200.broadcom.net> <1239731057.3357.71.camel@mulgrave.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>, Robin Holt <holt@sgi.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	Parisc List <linux-parisc@vger.kernel.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:34912 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755588AbZDNSWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2009 14:22:41 -0400
Content-Disposition: inline
In-Reply-To: <1239731057.3357.71.camel@mulgrave.int.hansenpartnership.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 05:44:17PM +0000, James Bottomley wrote:
> On Tue, 2009-04-14 at 10:21 -0700, Matt Carlson wrote:
> > James, Robin.  I looked through the patches again and found that the
> > SEEPROM routines were not being adjusted correctly along with the flash
> > NVRAM access routines.  The patch below should shore up the difference.
> > The patch works on both BE and LE systems.
> > 
> > Can you apply the patch below and see if it fixes your problem?  (You
> > may have to back out David's changes for the mac addresses to be
> > restored, but 'eeprom -e' dumps should be fixed.)  If it does, I'll
> > post a replacement patch that documents why the code is doing what it's
> > doing.
> 
> Yes, that seems to work better:  both the mac address and ethtool -e
> output are back to what 2.6.29 reports.

Works for me as well.

Thanks,
Robin

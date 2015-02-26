From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH v2 1/1] linux-firmware: Add QLogic BR Series Adapter
 Firmware
Date: Thu, 26 Feb 2015 15:23:34 -0500
Message-ID: <20150226202334.GQ30928@merlin.infradead.org>
References: <1424218220-28837-1-git-send-email-rasesh.mody@qlogic.com>
 <20150224175841.GO30928@merlin.infradead.org>
 <2552F74A0BCCBE4DBE2AD218C81B2811D8E4D4@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle McMartin <kyle@infradead.org>,
	"linux-firmware@kernel.org" <linux-firmware@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>
To: Rasesh Mody <rasesh.mody@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:33216 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbbBZUXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:23:38 -0500
Content-Disposition: inline
In-Reply-To: <2552F74A0BCCBE4DBE2AD218C81B2811D8E4D4@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 07:31:43PM +0000, Rasesh Mody wrote:
> > From: Kyle McMartin [mailto:kyle@infradead.org]
> > Sent: Tuesday, February 24, 2015 9:59 AM
> > 
> > On Tue, Feb 17, 2015 at 07:10:20PM -0500, Rasesh Mody wrote:
> > > This patch rebrands the BFA/BNA inbox driver firmwares.
> > > This patch adds 3.2.5.1 firmware files for QLogic BR-series Adapters
> > > that will be used with the inbox drivers(BFA and BNA).
> > >
> > > Signed-off-by: Rasesh Mody <rasesh.mody@qlogic.com>
> > > ---
> > >  WHENCE            |  13 +++++++++----
> > >  cbfw-3.2.5.1.bin  | Bin 0 -> 414480 bytes  ct2fw-3.2.5.1.bin | Bin 0
> > > -> 584216 bytes  ctfw-3.2.5.1.bin  | Bin 0 -> 539144 bytes
> > >  4 files changed, 9 insertions(+), 4 deletions(-)  create mode 100644
> > > cbfw-3.2.5.1.bin  create mode 100644 ct2fw-3.2.5.1.bin  create mode
> > > 100644 ctfw-3.2.5.1.bin
> > >
> > 
> > Thanks, applied. Any chance on the next update of the firmware we could
> > move to putting new files under qlogic/*.bin?
> 
> Thanks Kyle, will keep that in mind.
> 

Thanks! It's not a huge deal, since we don't remove the old ones, but
it'd be quite nice to reduce clutter (or even define a new directory if
you feel like coming up with a name. :)

Since all 3 files need to match for the bfa/bna drivers anyway, it'd also
be nice to wrap the 3 in a single container and parse that, but again,
that's just me being a bit pedantic. :)

Thanks!
--Kyle

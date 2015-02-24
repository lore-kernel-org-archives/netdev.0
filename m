From: Robert Dolca <robert.dolca@intel.com>
Subject: Re: [PATCH 8/8] NFC: Add Intel FieldsPeak NFC solution driver
Date: Tue, 24 Feb 2015 12:46:49 +0200
Message-ID: <20150224104648.GA28148@rdolca-desk.ger.corp.intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
 <1424773990.2192.27.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc@ml01.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424773990.2192.27.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 24, 2015 at 11:33:10AM +0100, Johannes Berg wrote:
> > +config NFC_FDP
> > +	tristate "Intel FDP NFC driver"
> > +	depends on NFC_NCI
> > +	select CRC_CCITT
> > +	default n
> > +	---help---
> > +	  Intel FDP core driver.
> > +	  This is a driver based on the NCI NFC kernel layers.
> > +
> > +	  To compile this driver as a module, choose m here. The module will
> > +	  be called pn547.
>
> this seems like a copy/paste error? Certainly it's called fdp?

You are right. It should be FDP instead of pn547.

I will also rename the menu entry name from "Intel FDP NFC driver" to
"Intel FieldsPeak (FDP) NFC driver" to be more clear what FDP means.

Thanks,
Robert

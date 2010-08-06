From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of
 pseduo-platform busses
Date: Fri, 6 Aug 2010 07:27:27 -0700
Message-ID: <20100806142727.GB4921@suse.de>
References: <4C58A7AA.8020007@codeaurora.org>
 <20100803235631.GA17759@suse.de>
 <4C58AE15.6090900@codeaurora.org>
 <20100804000945.GA19729@suse.de>
 <4C58B1B6.9050005@quicinc.com>
 <AANLkTikVzh9=DvvUPbKmDeo6k2-pPVSnjH+GxAPdQFO4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Pannuto <ppannuto@quicinc.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "dtor@mail.ru" <dtor@mail.ru>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikVzh9=DvvUPbKmDeo6k2-pPVSnjH+GxAPdQFO4@mail.gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 05, 2010 at 04:59:35PM -0600, Grant Likely wrote:
> (On that point Greg, what is the reason for even having the
> /sys/devices/platform/ parent?  Why not just let the platform devices
> sit at the root of the device tree?  In the OF case (granted, I'm
> biased) all of the platform_device registrations reflect the actual
> device hierarchy expressed in the device tree data.)

If we sat them at the "root", there would be a bunch of them there.  I
don't know, we could drop the parent, I guess whoever created the
platform device oh so long ago, decided that it would look nicer to be
in this type of structure.

> Now, having gone on this whole long tirade, it looks like having
> separate platform bus types may not be the best approach after all.

I totally agree, and thanks for the detailed explaination, it saved me
from having to write up the same thing :)

greg k-h

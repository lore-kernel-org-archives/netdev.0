From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/2] net: ethtool: Add capability to retrieve
 plug-in module EEPROM
Date: Wed, 11 Apr 2012 19:16:57 +0100
Message-ID: <1334168217.2552.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F71FE0A.3060203@solarflare.com>
	 <1333389160.2623.30.camel@bwh-desktop.uk.solarflarecom.com>
	 <4F85B639.5090900@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bruce.w.allan@intel.com>,
	<mirq-linux@rere.qmqm.pl>, <decot@google.com>,
	<amit.salecha@qlogic.com>, <alexander.h.duyck@intel.com>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Stuart Hodgson <smhodgson@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F85B639.5090900@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-04-11 at 17:50 +0100, Stuart Hodgson wrote:
> On 02/04/12 18:52, Ben Hutchings wrote:
[...]
> >> --- a/net/core/ethtool.c
> >> +++ b/net/core/ethtool.c
[...]
> >> +    if (eeprom.offset + eeprom.len>  modinfo.eeprom_len)
> >> +        return -EINVAL;
> >> +
> >> +    data = kmalloc(PAGE_SIZE, GFP_USER);
> >> +    if (!data)
> >> +        return -ENOMEM;
> >
> > What if some device has a larger EEPROM?  Surely this length should be
> > eeprom.len.
> >
> 
> Do you mean what if the eeprom length in te device is larger than
> PAGE_SIZE?

Yes.

> If so then it should really use modinfo.eeprom_len since
> this the size of the data. eeprom.len could be arbitary.

No, eeprom.len is the size of the data and we've already validated it at
this point.

Ben.

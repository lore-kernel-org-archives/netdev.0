From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [lm-sensors] [PATCH 0/5] net: hwmon fixes
Date: Mon, 25 Nov 2013 20:34:03 +0100
Message-ID: <20131125203403.1e9ed382@endymion.delvare>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	<1385225290.20467.73.camel@deadeye.wl.decadent.org.uk>
	<5290E0B9.1030606@roeck-us.net>
	<1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>
	<20131125192334.580400ef@endymion.delvare>
	<1385405786.1586.44.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<lm-sensors@lm-sensors.org>, Greg Rose <gregory.v.rose@intel.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zoneX.GCU-Squad.org ([194.213.125.0]:20585 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab3KYTeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 14:34:23 -0500
In-Reply-To: <1385405786.1586.44.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Nov 2013 18:56:26 +0000, Ben Hutchings wrote:
> On Mon, 2013-11-25 at 19:23 +0100, Jean Delvare wrote:
> > On Mon, 25 Nov 2013 17:15:50 +0000, Ben Hutchings wrote:
> > > We don't attach them to the hwmon device either, and I would rather not
> > > change that yet because lm-sensors 2 is still widely used.
> > 
> > Mouahahahah.
> > 
> > No, seriously, it's not.
> 
> RHEL 5 has it, and that is widely used - even with recent mainline
> kernels, in some cases.

RHEL 5 comes with kernel 2.6.18, which isn't exactly recent. I very
much doubt a significant share of users dare to use a brand new kernel
on such an old distribution. And if they do, then there are several
packages which need to be updated (udev, kernel-firmware...),
lm-sensors is only one of them, and the user should be aware of that.

> > And lm-sensors 2 doesn't even support your
> > device so this is a totally moot point.
> 
> I thought it did work with arbitrary devices providing the right
> attributes, but obviously I misremembered.

This is how lm-sensors 3 works. But lm-sensors 2 needs explicit support
for each and every device. Which is exactly why version 2 sucked and
nobody should be using it any longer.

> So there's no reason not to change.  Thanks.

Good to hear :)

-- 
Jean Delvare

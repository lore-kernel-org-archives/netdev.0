From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [lm-sensors] [PATCH 0/5] net: hwmon fixes
Date: Mon, 25 Nov 2013 18:56:26 +0000
Message-ID: <1385405786.1586.44.camel@bwh-desktop.uk.level5networks.com>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	 <1385225290.20467.73.camel@deadeye.wl.decadent.org.uk>
	 <5290E0B9.1030606@roeck-us.net>
	 <1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>
	 <20131125192334.580400ef@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
To: Jean Delvare <khali@linux-fr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6166 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756846Ab3KYS4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 13:56:33 -0500
In-Reply-To: <20131125192334.580400ef@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-25 at 19:23 +0100, Jean Delvare wrote:
> On Mon, 25 Nov 2013 17:15:50 +0000, Ben Hutchings wrote:
> > On Sat, 2013-11-23 at 09:07 -0800, Guenter Roeck wrote:
> > > Yes, I know about that one. It concluded that it would be too invasive
> > > and risky to try to fix it without access to hardware to test the results.
> > > That is why I said "fixes _most_ of the problems".
> > > 
> > > As for why the attributes are created after registration, it was most likely
> > > because there was no API available to attach the sysfs attributes to
> > > the hwmon device in a clean way. The new APIs fix that.
> > 
> > We don't attach them to the hwmon device either, and I would rather not
> > change that yet because lm-sensors 2 is still widely used.
> 
> Mouahahahah.
> 
> No, seriously, it's not.

RHEL 5 has it, and that is widely used - even with recent mainline
kernels, in some cases.

> And lm-sensors 2 doesn't even support your
> device so this is a totally moot point.

I thought it did work with arbitrary devices providing the right
attributes, but obviously I misremembered.  So there's no reason not to
change.  Thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

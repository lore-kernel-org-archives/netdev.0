From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [lm-sensors] [PATCH 0/5] net: hwmon fixes
Date: Mon, 25 Nov 2013 19:23:34 +0100
Message-ID: <20131125192334.580400ef@endymion.delvare>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	<1385225290.20467.73.camel@deadeye.wl.decadent.org.uk>
	<5290E0B9.1030606@roeck-us.net>
	<1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	lm-sensors@lm-sensors.org, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zoneX.GCU-Squad.org ([194.213.125.0]:42548 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756170Ab3KYSX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 13:23:57 -0500
In-Reply-To: <1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Nov 2013 17:15:50 +0000, Ben Hutchings wrote:
> On Sat, 2013-11-23 at 09:07 -0800, Guenter Roeck wrote:
> > Yes, I know about that one. It concluded that it would be too invasive
> > and risky to try to fix it without access to hardware to test the results.
> > That is why I said "fixes _most_ of the problems".
> > 
> > As for why the attributes are created after registration, it was most likely
> > because there was no API available to attach the sysfs attributes to
> > the hwmon device in a clean way. The new APIs fix that.
> 
> We don't attach them to the hwmon device either, and I would rather not
> change that yet because lm-sensors 2 is still widely used.

Mouahahahah.

No, seriously, it's not. And lm-sensors 2 doesn't even support your
device so this is a totally moot point.

-- 
Jean Delvare

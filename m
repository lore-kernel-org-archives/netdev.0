From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Sat, 29 Nov 2008 23:05:02 -0500
Message-ID: <1228017902.15002.11.camel@68-244-216-173.pools.spcsdns.net>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <1227783281.3809.78.camel@johannes.berg>
	 <00E41CD2-3C1B-4B39-8720-698DBC236CE8@holtmann.org>
	 <1227785032.3809.84.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60842 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbYK3EF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Nov 2008 23:05:59 -0500
In-Reply-To: <1227785032.3809.84.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-27 at 12:23 +0100, Johannes Berg wrote:
> > The idea is to make the WiMAX subsystem more generic and create  
> > something similar to what we have with mac80211/cfg80211 and also  
> > inside Bluetooth. This is the common starting point and next step is  
> > to move functionality that has been identified as generic and common  
> > from the driver into the subsystem.
> 
> The problem is with the current stack design this isn't really possible,
> since the stack only provides like three real commands:
>  * talk to driver
>  * reset device
>  * do rfkill (though I'm not sure why this is needed)
> 
> > I prefer if we do this development inside the kernel tree instead of  
> > externally. One big thing we should have learned from mac80211 is that  
> > developing a full stack outside the kernel source tree is not really  
> > working out. We should apply the same model as we did for ext4 or what  
> > Greg is doing with his staging tree.
> 
> The problem with that is that the stack is setting APIs in stone that
> are, if you ask me, suboptimal. Once we add those, I don't see how we
> can migrate away from a "command handled by driver" model towards a
> "command handled by stack and appropriate driver callback called" model,
> which would be more like cfg80211/nl80211 rather than iwpriv.
> 
> > It has been open source since quite some time now at linuxwimax.org  
> > (exception are some tiny binary pieces).
> 
> Ok, sorry, I thought there was a bunch of binary code still.

The 802.1x supplicant still is.

Dan



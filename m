From: Jiri Benc <jbenc@suse.cz>
Subject: Re: rt2x00/rt2500 support
Date: Fri, 14 Jul 2006 13:33:58 +0200
Message-ID: <20060714133358.1a2f1aa0@griffin.suse.cz>
References: <op.tcib4hf2r1uuuo@localhost>
	<1152652081.27683.10.camel@localhost.localdomain>
	<op.tcjngot1r1uuuo@localhost>
	<1152653806.27683.16.camel@localhost.localdomain>
	<op.tcjobte7r1uuuo@localhost>
	<1152655727.27683.23.camel@localhost.localdomain>
	<op.tclk82o1r1uuuo@localhost>
	<1152807957.2698.10.camel@localhost.localdomain>
	<op.tcm55p06r1uuuo@localhost>
	<1152822989.22332.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eion Robb <emr33@student.canterbury.ac.nz>,
	networkmanager-list@gnome.org, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:3983 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932500AbWGNLeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 07:34:00 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1152822989.22332.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Jul 2006 16:36:29 -0400, Dan Williams wrote:
> Ok; this is because d80211 (at least as included in rt2x00 driver) isn't
> setting the wireless stats handler, which I believe makes the device
> show up in /proc/net/wireless.
> (...)
> 
> Jiri, what's involved here?  The actual handler for get_wireless_stats
> is quite simple; see below.  It returns a 'struct iw_statistics' for
> which it looks like all the information is available in d80211
> elsewhere.

There is no specific reason, nobody just have cared so far.

I think HAL is broken if it requires /proc/net/wireless to recognize
wireless device. There are better ways to achieve this (e.g. WE-specific
ioctls).

I put this request to the TODO list; that means it will be fixed but not
in a near future. Feel free to send a patch if you want it earlier.

Thanks,

 Jiri

> > > AFAIK, HAL looks at /proc/net/wireless, parses the interface names, and
> > > uses that to determine whether or not the device is a wireless device.
> > > Since it appears that /proc/net/wireless is eventually going away, HAL
> > > may need to get changed to recognize the /sys/class/ieee80211 directory
> > > that dscape presents, or something like that.

-- 
Jiri Benc
SUSE Labs

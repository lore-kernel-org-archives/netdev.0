From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 19:53:04 +0100
Message-ID: <1255459984.13438.2.camel@achroite>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009145137.GD19218@mock.linuxdev.us.dell.com>
	 <1255344075.2143.1.camel@warcraft>
	 <20091012173705.GA22736@nostromo.devel.redhat.com>
	 <1255457182.2196.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bill Nottingham <notting@redhat.com>,
	Scott James Remnant <scott@ubuntu.com>,
	Matt Domsch <Matt_Domsch@dell.com>,
	Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39184 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933969AbZJMSxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 14:53:43 -0400
In-Reply-To: <1255457182.2196.21.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-13 at 11:06 -0700, Dan Williams wrote:
> On Mon, 2009-10-12 at 13:37 -0400, Bill Nottingham wrote:
> > Scott James Remnant (scott@ubuntu.com) said: 
> > > On the other hand, they *tend* to be unique for a wide range of systems.
> > > This makes them pretty comparable to LABELs on disks, and we have
> > > a /dev/disk/by-label
> > > 
> > > Remember that udev already supports symlink stacking, and priorities and
> > > such.
> > > 
> > > I don't think there's any danger of supporting a /dev/netdev/by-mac by
> > > default, it'll be a benefit to most and those who don't have unique MACs
> > > will just ignore it.
> > 
> > At the moment, we do not appear to get the proper change uevents from things
> > like 'ip link set dev <foo> address <bar>', so we can't currently maintain
> > these symlinks.
> 
> And if we really want seamless support for MAC spoofing, we want
> ETHTOOL_GPERMADDR for all drivers too, so that if your configuration
> says "rename device XX:XX:XX:XX:XX:XX to YY:YY:YY:YY:YY:YY" we can
> actually figure stuff out after the spoof.

ETHTOOL_GPERMADDR is handled in the ethtool core now.  Are you thinking
of drivers that don't have ethtool ops?  Maybe it's time to add default
operations.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


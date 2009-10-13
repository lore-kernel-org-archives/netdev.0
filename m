From: Dan Williams <dcbw@redhat.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 11:06:22 -0700
Message-ID: <1255457182.2196.21.camel@localhost.localdomain>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009145137.GD19218@mock.linuxdev.us.dell.com>
	 <1255344075.2143.1.camel@warcraft>
	 <20091012173705.GA22736@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Scott James Remnant <scott@ubuntu.com>,
	Matt Domsch <Matt_Domsch@dell.com>,
	Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Bill Nottingham <notting@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933902AbZJMSGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 14:06:50 -0400
In-Reply-To: <20091012173705.GA22736@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-10-12 at 13:37 -0400, Bill Nottingham wrote:
> Scott James Remnant (scott@ubuntu.com) said: 
> > On the other hand, they *tend* to be unique for a wide range of systems.
> > This makes them pretty comparable to LABELs on disks, and we have
> > a /dev/disk/by-label
> > 
> > Remember that udev already supports symlink stacking, and priorities and
> > such.
> > 
> > I don't think there's any danger of supporting a /dev/netdev/by-mac by
> > default, it'll be a benefit to most and those who don't have unique MACs
> > will just ignore it.
> 
> At the moment, we do not appear to get the proper change uevents from things
> like 'ip link set dev <foo> address <bar>', so we can't currently maintain
> these symlinks.

And if we really want seamless support for MAC spoofing, we want
ETHTOOL_GPERMADDR for all drivers too, so that if your configuration
says "rename device XX:XX:XX:XX:XX:XX to YY:YY:YY:YY:YY:YY" we can
actually figure stuff out after the spoof.

Dan



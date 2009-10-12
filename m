From: Bill Nottingham <notting@redhat.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 13:37:06 -0400
Message-ID: <20091012173705.GA22736@nostromo.devel.redhat.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
 <20091009145137.GD19218@mock.linuxdev.us.dell.com>
 <1255344075.2143.1.camel@warcraft>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Scott James Remnant <scott@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757347AbZJLRhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2009 13:37:41 -0400
Content-Disposition: inline
In-Reply-To: <1255344075.2143.1.camel@warcraft>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott James Remnant (scott@ubuntu.com) said: 
> On the other hand, they *tend* to be unique for a wide range of systems.
> This makes them pretty comparable to LABELs on disks, and we have
> a /dev/disk/by-label
> 
> Remember that udev already supports symlink stacking, and priorities and
> such.
> 
> I don't think there's any danger of supporting a /dev/netdev/by-mac by
> default, it'll be a benefit to most and those who don't have unique MACs
> will just ignore it.

At the moment, we do not appear to get the proper change uevents from things
like 'ip link set dev <foo> address <bar>', so we can't currently maintain
these symlinks.

Bill

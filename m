From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 4/7] d80211: add support for SIOCSIWNICKN SIOCGIWNICKN
Date: Wed, 30 Aug 2006 09:36:30 -0400
Message-ID: <1156944990.2725.1.camel@localhost.localdomain>
References: <44F3572E.8020506@linux.intel.com>
	 <1156837757.3788.10.camel@ux156> <20060829114915.GB29669@tuxdriver.com>
	 <20060829174531.GH1701@instant802.com>
	 <20060829221553.GA31563@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:64429 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751028AbWH3NgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 09:36:04 -0400
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20060829221553.GA31563@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-30 at 00:15 +0200, Ulrich Kunitz wrote:
> On 06-08-29 10:45 Jouni Malinen wrote:
> 
> > The only reason for adding nick command would be to maintain backwards
> > compatibility with some scripts. I do not use any distro configuration
> > mechanisms for setting up wireless, so I do not know what is currently
> > being used. I would not add these ioctls into d80211 unless someone can
> > point out an existing (and widely used) mechanism that depends on these
> > ioctls being available.
> 
> The softmac-broadcom and the zd1211 driver are using it to give some
> information about the driver bound to the interface. I found it
> quite useful to know which driver is bound to which WLAN
> interface. A readonly driver text info field would get my support.

That's what the 'driver' link is for in sysfs.

[dcbw@localhost devel]$ ls -al /sys/class/net/eth1/device/
lrwxrwxrwx 1 root root    0 Aug 30 09:18 driver -> ../../../../bus/pci/drivers/ipw2200

Dan


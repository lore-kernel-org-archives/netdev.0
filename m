From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH 4/7] d80211: add support for SIOCSIWNICKN SIOCGIWNICKN
Date: Wed, 30 Aug 2006 00:15:53 +0200
Message-ID: <20060829221553.GA31563@p15091797.pureserver.info>
References: <44F3572E.8020506@linux.intel.com> <1156837757.3788.10.camel@ux156> <20060829114915.GB29669@tuxdriver.com> <20060829174531.GH1701@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:47869 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S965423AbWH2WPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:15:54 -0400
To: Jouni Malinen <jkm@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20060829174531.GH1701@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-29 10:45 Jouni Malinen wrote:

> The only reason for adding nick command would be to maintain backwards
> compatibility with some scripts. I do not use any distro configuration
> mechanisms for setting up wireless, so I do not know what is currently
> being used. I would not add these ioctls into d80211 unless someone can
> point out an existing (and widely used) mechanism that depends on these
> ioctls being available.

The softmac-broadcom and the zd1211 driver are using it to give some
information about the driver bound to the interface. I found it
quite useful to know which driver is bound to which WLAN
interface. A readonly driver text info field would get my support.

-- 
Uli Kunitz

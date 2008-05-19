From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Mon, 19 May 2008 10:03:47 -0700
Message-ID: <20080519170347.GB21500@bougret.hpl.hp.com>
References: <1211026337.3827.25.camel@johannes.berg> <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org> <1211032475.6252.2.camel@johannes.berg> <1211117795.686.15.camel@localhost.localdomain> <1211199368.6252.19.camel@johannes.berg> <1211210686.12187.6.camel@localhost.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	netdev <netdev@vger.kernel.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:57657 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694AbYESRPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 13:15:51 -0400
Content-Disposition: inline
In-Reply-To: <1211210686.12187.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2008 at 11:24:46AM -0400, Dan Williams wrote:
> On Mon, 2008-05-19 at 14:16 +0200, Johannes Berg wrote:
> > > Instead of testing for wireless/, best thing would probably be to call
> > > SIOCGIWRANGE on the device and if it returns EOPNOTSUP then it's not
> > > wireless.  Some drivers may have to load firmware to figure out
> > > supported rates and encryption capabilities, but to be honest, NM does
> > > this to detect wireless devices and I haven't run into any issues in 4
> > > years using it.  If there are issues with drivers, then we need to fix
> > > the driver too.
> > 
> > I was about to propose calling SIOCGIWNAME since that is what
> > wireless-tools do and that linux/wireless.h indicates.
> 
> Hmm; NAME is pretty useless.  That's fine to do, I guess WEXT requires
> that NAME return _something_ at least.  NAME should never ever be used
> for anything more, but since wireless-tools appears to do this that's
> fine.
> 
> Dan

	It's not useless, it's supposed to tell you about the protocol
capability of the device, like "IEEE 802.11b" or "IEEE 802.11abg".

	Have fun...

	Jean


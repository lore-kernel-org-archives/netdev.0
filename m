From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Mon, 19 May 2008 10:01:45 -0700
Message-ID: <20080519170145.GA21500@bougret.hpl.hp.com>
References: <1211026337.3827.25.camel@johannes.berg> <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org> <1211032475.6252.2.camel@johannes.berg> <1211117795.686.15.camel@localhost.localdomain> <1211199368.6252.19.camel@johannes.berg>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	netdev <netdev@vger.kernel.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:14711 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbYESRDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 13:03:51 -0400
Content-Disposition: inline
In-Reply-To: <1211199368.6252.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2008 at 02:16:08PM +0200, Johannes Berg wrote:
> 
> > Instead of testing for wireless/, best thing would probably be to call
> > SIOCGIWRANGE on the device and if it returns EOPNOTSUP then it's not
> > wireless.  Some drivers may have to load firmware to figure out
> > supported rates and encryption capabilities, but to be honest, NM does
> > this to detect wireless devices and I haven't run into any issues in 4
> > years using it.  If there are issues with drivers, then we need to fix
> > the driver too.
> 
> I was about to propose calling SIOCGIWNAME since that is what
> wireless-tools do and that linux/wireless.h indicates.
> 
> johannes

	Yes, using SIOCGIWNAME is the right way to do it, it's the
only ioctl that is guarantee to always be present and require minimal
processing from the driver (it should be a static string). If you look
at iwconfig, this is how it does it.
	(Sorry for the delay replying, I was chasing kids and
electrical faults this week end).

	Have fun...

	Jean


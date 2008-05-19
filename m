From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Mon, 19 May 2008 11:24:46 -0400
Message-ID: <1211210686.12187.6.camel@localhost.localdomain>
References: <1211026337.3827.25.camel@johannes.berg>
	 <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
	 (sfid-20080517_154639_384202_6D3479C2)  <1211032475.6252.2.camel@johannes.berg>
	 <1211117795.686.15.camel@localhost.localdomain>
	 <1211199368.6252.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	netdev <netdev@vger.kernel.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762130AbYESP27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 11:28:59 -0400
In-Reply-To: <1211199368.6252.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-19 at 14:16 +0200, Johannes Berg wrote:
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

Hmm; NAME is pretty useless.  That's fine to do, I guess WEXT requires
that NAME return _something_ at least.  NAME should never ever be used
for anything more, but since wireless-tools appears to do this that's
fine.

Dan



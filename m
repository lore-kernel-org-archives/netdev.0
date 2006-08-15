From: Michael Buesch <mb@bu3sch.de>
Subject: Re: proposal for new wireless configuration API
Date: Tue, 15 Aug 2006 18:38:57 +0200
Message-ID: <200608151838.58182.mb@bu3sch.de>
References: <1155655728.17742.30.camel@ux156> <1155659387.3005.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44509
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030383AbWHOQk3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 12:40:29 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1155659387.3005.15.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 August 2006 18:29, Dan Williams wrote:
> o Separate attributes for channel and frequency

No, channel and freq is the same. It's just another name
for the same child. I would say we only want to deal with channel numbers
in the API. That's much easier, as we don't have to deal with this
fixed-point (or even floating point) mess. Look at WE for the
fixed-point mess.
The userspace tools can easily convert freq to channel and back.
And in the kernel, we can easily provide some small function
to convert from channel to khz and back, for example. But I would
like to see the fixed-point stuff in the API vanish.

> o Method of finding out channel <-> frequency mapping (not all drivers
> support this in the SIOCGIWRANGE handler now)

Yes, that would be a good idea.
Comes next to the conversion function (see above).

-- 
Greetings Michael.

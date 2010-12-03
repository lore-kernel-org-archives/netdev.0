From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ethtool : Allow ethtool to set interface in
 loopback mode.
Date: Fri, 03 Dec 2010 16:33:34 +0000
Message-ID: <1291394014.13384.7.camel@bwh-desktop>
References: <AANLkTikxHDksqrvG4uNJ8JVY5AJgcftQy2F4ihJBV=TE@mail.gmail.com>
	 <1291299660.3259.5.camel@bwh-desktop>
	 <AANLkTi=GygGKnuSZmWecmGejDjzLx2uaHuk+DroVfHDy@mail.gmail.com>
	 <20101203160333.GA235120@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2865 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab0LCQdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 11:33:37 -0500
In-Reply-To: <20101203160333.GA235120@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-03 at 17:03 +0100, David Lamparter wrote:
> On Thu, Dec 02, 2010 at 02:35:51PM -0800, Mahesh Bandewar wrote:
> > This patch adds -L command-line option to switch loopback mode on/off
> > and -l option to display current loopback mode on a specified interface.
> [...]
> > +.A1 on off
> > +Switches loopback mode
> > +.B on
> > +or
> > +.B off
> 
> What about devices that support different kinds of loopback, like MAC
> loopback & PHY loopback? (No idea if we have kernel support for this
> either...)

That distinction is useful for diagnostic purposes, but drivers can
already cover those different loopback modes in self-test.  The
motivation for this feature is testing data path behaviour, and Mahesh
has specified that loopback should be enabled as near as possible to the
host.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


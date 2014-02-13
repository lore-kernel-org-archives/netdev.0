From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 3/3] cfg80211: add MPLS and 802.21 classification
Date: Thu, 13 Feb 2014 03:14:08 -0800
Message-ID: <1392290048.2214.41.camel@joe-AO722>
References: <1392202386-8826-1-git-send-email-sw@simonwunderlich.de>
	 <1392202386-8826-4-git-send-email-sw@simonwunderlich.de>
	 <1392205783.1868.5.camel@joe-AO722>
	 <201402131146.01749.sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de
To: Simon Wunderlich <sw@simonwunderlich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0108.hostedemail.com ([216.40.44.108]:45097 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752144AbaBMLOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 06:14:11 -0500
In-Reply-To: <201402131146.01749.sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-13 at 11:46 +0100, Simon Wunderlich wrote:

Hi Simon

> > On Wed, 2014-02-12 at 11:53 +0100, Simon Wunderlich wrote:
> > > MPLS labels may contain traffic control information, which should be
> > > evaluated and used by the wireless subsystem if present.
[]
> > > diff --git a/net/wireless/util.c b/net/wireless/util.c
[]
> > > +#include <uapi/linux/mpls.h>
> > 
> > Please try not to #include uapi files.
> why not? The packet definition header has been put in UAPI, so I need that 
> there ... or should we move that to some place else? Other protocol definition 
> headers like IP, udp, tcp have been defined in uapi to the same way, so I 
> figured that would be the right position.

It seems the practice is to have another include/<net|linux>/mpls.h
file that #includes the <uapi/linux/mpls.h>

For instance, look at:

include/linux/udp.h

It does #include <uapi/linux/udp.h>

All the other kernel sources use

#include <linux/udp.h>

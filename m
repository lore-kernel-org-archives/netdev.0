From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute2 PATCH] ip-link: do not support 'ip link add dev help'
Date: Mon, 21 Sep 2015 22:26:59 +0200
Message-ID: <20150921202659.GU24212@orbit.nwl.cc>
References: <CAK8ArgOM2Vyr4DJO73wzhgFFbGMm9p+XMGcD2JAWeZ8G+_3PSw@mail.gmail.com>
 <1442863981-19112-1-git-send-email-phil@nwl.cc>
 <20150921221349.83034aoqadvokjr1@berry.schulz.ip-v6.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Wilhelm Wijkander <lists@0x5e.se>,
	Vadim Kochan <vadim4j@gmail.com>
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:44073 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932383AbbIUU1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 16:27:00 -0400
Content-Disposition: inline
In-Reply-To: <20150921221349.83034aoqadvokjr1@berry.schulz.ip-v6.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 10:13:49PM +0200, Christoph Schulz wrote:
> Phil Sutter schrieb am Mon, 21 Sep 2015 21:33:01 +0200:
> 
> > Commit 0532555 ('Support "ip link add help" for rtnl_link API') added a
> > check for specified help parameter. Though due to the place where it has
> > been added to, it is not possible anymore to force a given parameter to
> > be interpreted as interface name by prefixing it with 'dev '. Fix this
> > by forcing whatever follows 'dev' to be presumed as interface name.
> 
> I proposed a similar fix which also handles other ip commands, see  
> http://patchwork.ozlabs.org/patch/519171/ . Does my patch also work  
> for you?

Yes, this works just as well. Although I would personally prefer
reordering the conditionals, but that's probably just a matter of taste.

Cheers, Phil

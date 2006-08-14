From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Mon, 14 Aug 2006 09:13:23 +0400
Message-ID: <20060814051323.GA1335@2ka.mipt.ru>
References: <1155127040.12225.25.camel@twins> <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins> <20060809.165431.118952392.davem@davemloft.net> <1155189988.12225.100.camel@twins> <44DF888F.1010601@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:22417 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751848AbWHNFN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 01:13:59 -0400
To: Daniel Phillips <phillips@google.com>
Content-Disposition: inline
In-Reply-To: <44DF888F.1010601@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 13, 2006 at 01:16:15PM -0700, Daniel Phillips (phillips@google.com) wrote:
> Indeed.  The rest of the corner cases like netfilter, layered protocol and
> so on need to be handled, however they do not need to be handled right now
> in order to make remote storage on a lan work properly.  The sane thing for
> the immediate future is to flag each socket as safe for remote block IO or
> not, then gradually widen the scope of what is safe.  We need to set up an
> opt in strategy for network block IO that views such network subsystems as
> ipfilter as not safe by default, until somebody puts in the work to make
> them safe.

Just for clarification - it will be completely impossible to login using 
openssh or some other priveledge separation protocol to the machine due
to the nature of unix sockets. So you will be unable to manage your
storage system just because it is in OOM - it is not what is expected
from reliable system.

> But really, if you expect to run reliable block IO to Zanzibar over an ssh
> tunnel through a firewall, then you might also consider taking up bungie
> jumping with the cord tied to your neck.

Just pure openssh for control connection (admin should be able to
login).

> Regards,
> 
> Daniel

-- 
	Evgeniy Polyakov

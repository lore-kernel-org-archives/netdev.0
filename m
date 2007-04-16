From: "Denys" <denys@visp.net.lb>
Subject: Re: [Bugme-new] [Bug 8325] New: -j REDIRECT --to-ports 1000-1009, always first choosen
Date: Mon, 16 Apr 2007 08:45:29 +0300
Message-ID: <20070416054247.M18950@visp.net.lb>
References: <200704132053.l3DKrC9X000466@fire-2.osdl.org> <20070413144702.8ebf1cfe.akpm@linux-foundation.org> <462305C1.9030007@trash.net> <20070416052535.M41456@visp.net.lb> <462309F9.6050005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: wijata@nec-labs.com, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:52123 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbXDPFpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 01:45:46 -0400
In-Reply-To: <462309F9.6050005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On Mon, 16 Apr 2007 07:30:33 +0200, Patrick McHardy wrote
> Denys wrote:
> > Sorry, i will put my IMHO, since i am using it too.
> > 
> > I guess it can be useful for load-balancing scenario.
> 
> That makes sense with using multiple IPs (and we support doing that),
> but whats the point of load-balancing to differenet *ports*?

Easy - for example i have my own TCP acceleration solution, which is using 
REDIRECT, then getsockopt/SO_ORIGINAL_DST to get original IP, then forwarding 
to compressed tunnel, stripping unneeded bytes (oh, my expensive satellite 
bandwidth). This way for example i can do some kind load-balancing for 
satellite bandwidth. But i have done it over -m statistic.

> 
> > Is there way to provide both ways?
> > Thinking... 60% done, But maybe this can be done over -m statistic already
> 
> 2.6.21-rc supports randomized port selection (with iptables userspace
> from SVN). Using the statistic match would work as well.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.


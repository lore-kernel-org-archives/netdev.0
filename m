From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: HFSC classes going out of bounds, regression in recent kernels?
Date: Tue, 6 Apr 2010 18:45:42 +0300
Message-ID: <201004061845.42766.nuclearcat@nuclearcat.com>
References: <201004061822.21735.nuclearcat@nuclearcat.com> <4BBB5543.40607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45483 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab0DFPqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 11:46:48 -0400
In-Reply-To: <4BBB5543.40607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 April 2010 18:37:39 Patrick McHardy wrote:
> Denys Fedorysychenko wrote:
> > I notice on one of my QoS machines that HFSC start going out of bandwidth
> > limits. The most terrible thing - it happens suddenly, and if i just
> > relaunch QoS script - everything will work fine.
> 
> That sounds like there's an overflow somewhere.
> 
> > I'm not sure it is not my mistake, but most probably it is a bug.
> > I can't tell for sure when it is happened, last kernel was on this
> > machine 2.6.28 i guess, or maybe even older.
> 
> Looking through the recent patches in this area, my prime suspect
> is the attached patch. Does reverting it make any difference?
> 
I will try to upgrade soon, it is critical router, so probably i will do this 
tonight. 
I guess with reverting this patch also it will hurt shaper resolution on high 
speeds... not a case for me, but for other people.

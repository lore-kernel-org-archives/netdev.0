From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IPv6 extension header privileges
Date: Fri, 20 May 2016 21:56:04 -0400
Message-ID: <20160521015604.GD2452@oracle.com>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18794 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbcEUB4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 21:56:21 -0400
Content-Disposition: inline
In-Reply-To: <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/21/16 02:20), Hannes Frederic Sowa wrote:
> 
> There are some options inherently protocol depending like the jumbo
> payload option, which should be under control of the kernel, or the
> router alert option for igmp, which causes packets to be steered towards
> the slow/software path of routers, which can be used for DoS attacks.
> 
> Setting CALIPSO options in IPv6 on packets as users would defeat the
> whole CALIPSO model, etc.
> 
> The RFC3542 requires at least some of the options in dst/hop-by-hop

"requires" is a strong word. 3542 declares it as a  "may" (lower case).
The only thing required strongly is IPV6_NEXTHOP itself.

I suspect 3542 was written at a time when hbh and dst opt were loosely
defined and the "may" is just a place-holder (i.e., it's not even a MAY)

> 
> AFAIK people worried about the parsing overhead and thus decided to
> block it for ordinary users.

That's probably more likely, esp for hbh options. It may also be 
interesting to find out what BSD does in these cases. 

--Sowmini 

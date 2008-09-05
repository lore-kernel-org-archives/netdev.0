From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: "Listenless" TCP over NAT?
Date: Fri, 5 Sep 2008 13:15:06 +0100
Message-ID: <20080905121504.GJ7908@solarflare.com>
References: <WorldClient-F200809051345.AA45130148@butn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev <netdev@vger.kernel.org>,
	Linux Networking <linux-net@vger.kernel.org>
To: xerces8 <xerces8@butn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:39483 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752171AbYIEMPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 08:15:16 -0400
Content-Disposition: inline
In-Reply-To: <WorldClient-F200809051345.AA45130148@butn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xerces8 wrote:
> Hi!
> 
> Recently someone mentioned on this (or maybe other...) list a seldom used
> technique of establishing a TCP connection without one host listening on a port,
> but but acting as "clients" and connecting to the peers port.
> 
> My question: Can this be used to establish a TCP connection between two hosts that
> are both behind a (P)NAT router ?
> 
> (the idea being: NAT router lets outgoing connections thru, and in this case both
> NAT router would  see an "outgoing" connection)
> 
> If yes, this would simplify the life of many users :-)

It's a bit more complicated than that.  See
<http://en.wikipedia.org/wiki/TCP_hole_punching>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

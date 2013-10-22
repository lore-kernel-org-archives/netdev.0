From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Stale IPv6 address accumulation on linux 3.2.17
Date: Tue, 22 Oct 2013 12:18:11 +0200
Message-ID: <20131022101811.GA3200@order.stressinduktion.org>
References: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se> <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com> <Pine.LNX.4.61.1303272104470.20041@envy.nxs.se> <51535D16.4080207@katalix.com> <loom.20131021T165114-650@post.gmane.org> <2134F8430051B64F815C691A62D9831813520C@XCH-BLV-504.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50094 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3JVKSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 06:18:12 -0400
Content-Disposition: inline
In-Reply-To: <2134F8430051B64F815C691A62D9831813520C@XCH-BLV-504.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fred!

On Mon, Oct 21, 2013 at 03:50:24PM +0000, Templin, Fred L wrote:
> On linux 3.2.17, I have a host that configures IPv6 addresses on
> an eth0 interface based on Router Advertisements received from an
> on-link linux box configured as an IPv6 router and running radvd.
> When the host gets an RA, it configures both an EUI-64-based IPv6
> address and an IPv6 privacy address, so it has two IPv6 addresses.
> But, if I leave the host up for long periods of time, it seems to
> accumulate additional IPv6 addresses - perhaps these are stale
> IPv6 privacy addresses?
> 
> Is this known behavior, and if so is there a way to turn it off?
> Or, perhaps this was a known bug that has been corrected in more
> recent linux kernel versions?

Could you send me the output of ip -6 a l?

Greetings,

  Hannes

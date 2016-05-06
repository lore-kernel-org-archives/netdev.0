From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] geneve: fix IPv6 remote address reporting
Date: Fri, 6 May 2016 16:43:45 +0200
Message-ID: <20160506144345.GC11058@orbyte.nwl.cc>
References: <572CAA09.302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37157 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758517AbcEFOns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 10:43:48 -0400
Content-Disposition: inline
In-Reply-To: <572CAA09.302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2016 at 03:28:25PM +0100, Edward Cree wrote:
> Since we can only configure unicast, we probably want to be able to
> display unicast, rather than multicast.

Furthermore, the kernel even rejects multicast peer addresses.

> I'm assuming this is what was intended, but tbh I don't know why we
> need to check for multicast on the display side at all, rather than
> just displaying whatever the kernel gives us.

Why do you then propose a dubious fix to a dubious check instead of
getting rid of it in the first place? Reminds me a bit of this here (no
offense intended):

http://geekandpoke.typepad.com/geekandpoke/2011/07/good-coders.html

Cheers, Phil

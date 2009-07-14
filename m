From: Andreas Jaggi <aj@open.ch>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Tue, 14 Jul 2009 09:14:10 +0200
Message-ID: <20090714071410.GA4793@urbino.open.ch>
References: <20090713133225.GA20946@urbino.open.ch> <20090713.104433.244099298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:50509 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753901AbZGNHN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 03:13:59 -0400
Content-Disposition: inline
In-Reply-To: <20090713.104433.244099298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2009 at 10:44:33AM -0700, David Miller wrote:
> Why not just create a new IFLA_GRE_* attribute to pass in
> flags like this that purely are private to the GRE Linux
> tunnel driver and have nothing to do with values defined
> by GRE tunnel headers at all?

OK. What would be an appropriate place to store such a private flag in
the GRE driver?

I thought of extending the ip_tunnel_parms struct with '__u16 priv_flags'
(But this would break compatibility with the iproute2 tools?)

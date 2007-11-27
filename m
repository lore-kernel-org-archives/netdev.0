From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 15:00:22 -0800
Message-ID: <20071127150022.61bdff7e@freepuppy.rosehill>
References: <20071122343.446909000@suse.de>
	<200711261228.15155.rusty@rustcorp.com.au>
	<adahcj9sfan.fsf@cisco.com>
	<200711271549.37670.rusty@rustcorp.com.au>
	<1196202698.3415.119.camel@jcmlaptop>
	<20071127223743.GI24223@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jon Masters <jonathan@jonmasters.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59126 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752527AbXK0XCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 18:02:00 -0500
In-Reply-To: <20071127223743.GI24223@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 23:37:43 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> > With my "Enterprise" hat on, I can see where Andi was coming from
> > originally. 
> 
> For the record my original motivation was to fix the "TCP exports everything
> for ipv6.ko" case cleanly. I later realized that it would be useful for the
> ABI stability issues too, but it was really not my primary motivation.
> This is why I didn't even mention that in the original patch description.

Since ipv6 can never be removed because it references itself, the whole concept
of a modular ipv6 is flawed. Sometime ago a patch was sent to remove the ipv6 module
unload hooks but as I recall Dave rejected it believing the unload code could be
fixed.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>

From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: wireless vs. network namespaces (part II)
Date: Mon, 29 Sep 2008 12:03:45 -0700
Message-ID: <20080929190345.GD6203@tesla>
References: <1222509685.3798.59.camel@johannes.berg> <m1r675aw0l.fsf@frodo.ebiederm.org> <1222587651.3798.72.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:64437 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbYI2TD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 15:03:56 -0400
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Mon, 29 Sep 2008 12:03:56 -0700
Content-Disposition: inline
In-Reply-To: <1222587651.3798.72.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2008 at 12:40:51AM -0700, Johannes Berg wrote:
> On Sat, 2008-09-27 at 18:39 -0700, Eric W. Biederman wrote:
> > In the wired ethernet world there is a lot of value in moving just
> > a vlan interface or just one mac address with mac vlan into a network
> > namespace.  Allowing full speed access to the hardware that can do
> > just about anything while functionally restricting what user space
> > can do with the hardware.
> 
> Right, except that wireless really is different in that for one you
> can't really usefully have multiple virtual interfaces unless you're
> making an AP

Well it may be possible later in STA too, but that is just me looking at
a crystal ball.

> (and I think it's unlikely you'd want that in an AP, and
> even if I'm not willing to support it, 

You mean AP VLANs? I thought you added that code already. I don't
follow.

  Luis

From: Daniel Roesen <dr@cluenet.de>
Subject: Re: "src" attribute ignored for IPv6 (preferred source address
	selection)
Date: Sun, 17 Oct 2010 03:12:08 +0200
Message-ID: <20101017011205.GA10610@srv03.cluenet.de>
References: <4C8215C8.8000908@httrack.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.cluenet.de ([195.20.121.100]:55999 "EHLO mail1.cluenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757128Ab0JQBWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Oct 2010 21:22:50 -0400
Content-Disposition: inline
In-Reply-To: <4C8215C8.8000908@httrack.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 04, 2010 at 11:47:52AM +0200, Xavier Roche wrote:
> In an attempt to change the source address in various conditions (network 
> prefix, outgoing protocol, user owner id, ..), it appeared that the src 
> attribute of an IPv6 route command (ip -6 route add .. src ..) was simply 
> ignored.
>
> The outgoing interface can be selected, but not the preferred source 
> address (see (1)), which remains always the same within an interface.
>
> If this a bug ? Or a known limitation of the kernel ?

Well, at least it was a known limitation six years ago, when I
discovered the same:

http://lkml.indiana.edu/hypermail/linux/kernel/0409.0/1768.html

Unfortunately I don't have the time (and most probably not the necessary
kernel knowhow) to hack this up myself, but I'm still interested. :-)

Best regards,
Daniel

-- 
CLUE-RIPE -- Jabber: dr@cluenet.de -- dr@IRCnet -- PGP: 0xA85C8AA0

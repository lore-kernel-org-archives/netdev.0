From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 09:59:35 -0700
Message-ID: <OF8AA2B2D0.51E14DBC-ON88257448.005BC2A0-88257448.005D57D0@us.ibm.com>
References: <20080513162325.GF15306@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47483 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbYEMQ7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 12:59:39 -0400
In-Reply-To: <20080513162325.GF15306@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo Carvalho de Melo <acme@redhat.com> wrote on 05/13/2008 09:23:25 
AM:

> Em Tue, May 13, 2008 at 08:50:59AM -0700, David Stevens escreveu:
> > Are they mutually exclusive?
> > 
> > Why not add SOCK_DGRAM/IPPROTO_DCCP support while leaving
> 
> Because DCCP is not SOCK_DGRAM at all? :)

        Well, SOCK_STREAM/IPPROTO_DCCP then. :-) But it isn't really that
either, as Remi said.
        If you do a connect() on a UDP socket, it doesn't cease to
be a SOCK_DGRAM socket, so I don't really care about that distinction,
but if others do, that's ok with me. There are ACKs here, too, so maybe.
        My point was really that, though not as pretty, the world won't
end if there are two ways to get to the same kind of socket, and
especially if adding a new one makes getaddrinfo() easier to deal with.
If the best way isn't the existing way, we could add it, and keep the
old way for backward compatibility only.
        A "0" protocol had better continue to be TCP and UDP, and
specifying IPPROTO_DCCP makes it clear what the user wants, regardless
of the type. So "just working" (even with any of SOCK_DGRAM, SOCK_STREAM,
and SOCK_DCCP) seems perfectly reasonable to me. My $.02.
        A wrapper sound ok to me too.

                                                                +-DLS


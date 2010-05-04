From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 4 May 2010 10:05:16 -0700
Message-ID: <OFEC88F859.86FF615D-ON88257719.005D5A0F-88257719.005DDE16@us.ibm.com>
References: <4BE04E99.2080903@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, enh@google.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:39773 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932206Ab0EDRFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 13:05:30 -0400
In-Reply-To: <4BE04E99.2080903@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Yes, that would be the ideal fix, and give the admin more control over
> the value, but it seems like overkill to me.  It's been 64 for a while,
> and it's always been changeable by apps.  I guess the only thing to
> think about is there could be an app that works because it being 64
> today, but will break tomorrow.  Having a tunable parameter will let
> you get the app working without re-writing it.

        Well, it should've been 1, and any app relying on having
multicast routing really should set it explicitly.
        I think per-interface defaulting to 1 should be ok. I'd
prefer carrying the "-1" so apps that set it get what they want
and apps that don't carry the current default, rather than the
value at the time the socket was created, but practically it probably
doesn't matter. In reality, apps that need more than one will
already be setting it to a non-default value.

                                                        +-DLS


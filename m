From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 12:03:51 +0200
Message-ID: <200609191203.51045.ak@suse.de>
References: <20060918095936.GA6161@outpost.ds9a.nl> <20060918195224.GA26585@outpost.ds9a.nl> <20060918214104.3824a2e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bert hubert <bert.hubert@netherlabs.nl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:49862 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1030188AbWISKEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 06:04:06 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060918214104.3824a2e2@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 September 2006 06:41, Stephen Hemminger wrote:
> Bert's attempt was noble
> It showed your desire for the truth
> A simple path exists

I guess most people won't have a clue on what to configure here
(especially with such sparse help text, but even with more 
it would be hard). 

And you might end up with some weird error reports if someone
manages to configure one of the more broken algorithms.

How about a single auto selection heuristic: e.g. check the handshake latencies 
and if they are too long switch from reno to the newer one deemed most
stable?

-Andi

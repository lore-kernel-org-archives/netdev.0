From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: dsa: handling more than 1 cpu port
Date: Wed, 14 Dec 2016 11:31:53 +0100
Message-ID: <20161214103153.GC27370@lunn.ch>
References: <1671ae82-c213-7611-584f-02a3b1d5dff9@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54641 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755180AbcLNKb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 05:31:57 -0500
Content-Disposition: inline
In-Reply-To: <1671ae82-c213-7611-584f-02a3b1d5dff9@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2016 at 11:01:54AM +0100, John Crispin wrote:
> Hi Andrew,
> 
> switches supported by qca8k have 2 gmacs that we can wire an external
> mii interface to. Usually this is used to wire 2 of the SoCs MACs to the
> switch. Thw switch itself is aware of one of the MACs being the cpu port
> and expects this to be port/mac0. Using the other will break the
> hardware offloading features.

Just to be sure here. There is no way to use the second port connected
to the CPU as a CPU port?

The Marvell chips do allow this. So i developed a proof of concept
which had a mapping between cpu ports and slave ports. slave port X
should you cpu port y for its traffic. This never got past proof of
concept. 

If this can be made to work for qca8k, i would prefer having this
general concept, than specific hacks for pass through.

	Andrew

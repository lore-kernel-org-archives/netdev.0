From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC WIP 0/5] IGMP snooping for local traffic
Date: Sun, 27 Aug 2017 01:02:30 +0200
Message-ID: <20170826230230.GA13622@lunn.ch>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
 <c3f5050f-7a38-c28c-31d0-df5909259fb1@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>, jiri@mellanox.com,
        roopa@cumulusnetworks.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45204 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751117AbdHZXCd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Aug 2017 19:02:33 -0400
Content-Disposition: inline
In-Reply-To: <c3f5050f-7a38-c28c-31d0-df5909259fb1@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Andrew,
> 
> Have you taken a look at mglist (the boolean, probably needs a rename) ? It is for
> exactly that purpose, to track which groups the bridge is interested in.
> I assume I'm forgetting or missing something here.
> 
> > performed. With a pure software bridge, it is not required. All
> > mulitcast frames are passed to the brX interface, and the network
> 
> If mglist (again the boolean) is false then they won't be passed up.
> 
> > stack filters them, as it does for any interface. However, when
> > hardware offload is involved, things change. We should program the
> > hardware to only send multcast packets to the host when the host has
> > in interest in them.
> 
> Granted the boolean mglist might need some changes (esp. with host group leave)
> but I think it can be used to program switchdev for host join/leave, can't
> we adjust its behaviour instead of introducing this complexity and avoid many
> headaches ?

I would like to avoid this complexity as well. I will take a look at
mglist. Thanks for the hint.

	Andrew

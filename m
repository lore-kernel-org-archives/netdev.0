From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 1 May 2017 16:37:03 +0200
Message-ID: <20170501143703.GA1285@lunn.ch>
References: <CABM+yxkwQ1Oiw9p0tehLYyNgh6Qj=+1KKNk4hy35vz00DveyGA@mail.gmail.com>
 <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: carl h <heyen2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46746 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752959AbdEAOhF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 10:37:05 -0400
Content-Disposition: inline
In-Reply-To: <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > By what mechanism does the vlan driver (8021q.ko) tell the Ethernet
> > hardware about a vlan?

Why would the Ethernet hardware need to know?

An Ethernet Switch might need to know. If so, then switchdev would be
used, include/net/switchdev.h

    Andrew

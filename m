From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 3/4] net-next: dsa: fix flow dissection
Date: Fri, 28 Jul 2017 23:25:55 +0200
Message-ID: <20170728212555.GB11564@lunn.ch>
References: <20170721085813.30789-1-john@phrozen.org>
 <20170721085813.30789-3-john@phrozen.org>
 <20170726151013.GD12049@lunn.ch>
 <82b46393-6c63-eedf-25e4-2bd2278c0d16@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44348 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752569AbdG1V0E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 17:26:04 -0400
Content-Disposition: inline
In-Reply-To: <82b46393-6c63-eedf-25e4-2bd2278c0d16@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> thanks for the feedback. should I add 2 callbacks for each of the 2
> parameters ?

Hi John

A single callback is better. We don't want to have to peek into the
packet twice to determine two values.

       Andrew

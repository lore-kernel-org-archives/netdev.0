From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 1/2] net-next: fix DSA flow_disection
Date: Tue, 20 Jun 2017 16:01:40 +0200
Message-ID: <20170620140140.GB12383@lunn.ch>
References: <20170620080655.7251-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57147 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751094AbdFTOBu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 10:01:50 -0400
Content-Disposition: inline
In-Reply-To: <20170620080655.7251-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 20, 2017 at 10:06:54AM +0200, John Crispin wrote:
> RPS and probably other kernel features are currently broken on some if not
> all DSA devices. The root cause of this that skb_hash will call the
> flow_disector.

Hi John

What is the call path when the flow_disector is called? I'm wondering
if we can defer this, and call it later, after the tag code has
removed the header.

	Andrew

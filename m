From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 1/2] net-next: fix DSA flow_disection
Date: Tue, 20 Jun 2017 23:52:30 +0200
Message-ID: <20170620215230.GG12383@lunn.ch>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620140140.GB12383@lunn.ch>
 <390b4235-1bd4-89d2-3a5f-bc51e3599247@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57709 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751798AbdFTVws (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 17:52:48 -0400
Content-Disposition: inline
In-Reply-To: <390b4235-1bd4-89d2-3a5f-bc51e3599247@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, Jun 20, 2017 at 07:37:35PM +0200, John Crispin wrote:
> 
> 
> On 20/06/17 16:01, Andrew Lunn wrote:
> >On Tue, Jun 20, 2017 at 10:06:54AM +0200, John Crispin wrote:
> >>RPS and probably other kernel features are currently broken on some if not
> >>all DSA devices. The root cause of this that skb_hash will call the
> >>flow_disector.
> >Hi John
> >
> >What is the call path when the flow_disector is called? I'm wondering
> >if we can defer this, and call it later, after the tag code has
> >removed the header.
> >
> >	Andrew

Hi John

I follow your logic of doing the hash early

Is there any value in including the DSA header in the hash? That might
allow frames from different ingress ports to be spread over CPUs?

      Andrew

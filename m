From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 08:27:55 -0700
Message-ID: <20170906082755.58ff6c8f@xeon-e3>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
        <20170906004703.GB27385@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34621 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932263AbdIFP2D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 11:28:03 -0400
Received: by mail-pf0-f180.google.com with SMTP id m1so13325684pfk.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 08:28:03 -0700 (PDT)
In-Reply-To: <20170906004703.GB27385@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Sep 2017 02:47:03 +0200
Andrew Lunn <andrew@lunn.ch> wrote:

> > The third and last issue will be explained in a followup email.  
> 
> Hi DSA hackers
> 
> So there is the third issue. It affects just DSA, but it possible
> affects all DSA drivers.
> 
> This patchset broken broadcast with the Marvell drivers. It could
> break broadcast on others drivers as well.
> 
> What i found is that the Marvell chips don't flood broadcast frames
> between bridged ports. What appears to happen is there is a fdb miss,
> so it gets forwarded to the CPU port for the host to deal with. The
> software bridge when floods it out all ports of the bridge.
> 

That sounds like a good feature. There environments where you want
to disable broadcast between certain ports. It lets the bridge get
at the traffic for firewall filtering.

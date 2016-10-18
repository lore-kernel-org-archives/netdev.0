From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/6] net: phy: Threaded interrupts allow some
 simplification
Date: Tue, 18 Oct 2016 12:46:54 +0200
Message-ID: <20161018104654.GL26778@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-4-git-send-email-andrew@lunn.ch>
 <7997d337-cd0f-ab39-1f53-df996063932b@cogentembedded.com>
 <af8f7c76-f2fe-95ac-4151-0189baf84a53@cogentembedded.com>
 <20160928122835.GB22809@lunn.ch>
 <891f6b60-47a0-ba03-d6d3-8284993d1896@cogentembedded.com>
 <06bdfcb4-8bb6-28e6-00e5-2518f79f729d@gmail.com>
 <a3e6b467-9e44-1ed5-65ce-63c839dd3365@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47658 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753461AbcJRKq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 06:46:57 -0400
Content-Disposition: inline
In-Reply-To: <a3e6b467-9e44-1ed5-65ce-63c839dd3365@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>    Actually, I still don't know how to call phy_mac_interrupt() from
> the ravb driver because of the 'new_link' parameter -- I won't
> always have that signal connected to the MAC...

I'm not sure that parameter is of any use. I really think the
semantics of this call should be, something has changed, go and ask
the PHY driver to find out what. Just the same as if the PHY had
triggered an interrupt.

	  Andrew

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 13:28:57 +1100
Message-ID: <1490668137.3177.98.camel@kernel.crashing.org>
References: <1490662190.3177.91.camel@kernel.crashing.org>
         <20170328010940.GG25549@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50960 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753778AbdC1C3G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 22:29:06 -0400
In-Reply-To: <20170328010940.GG25549@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 03:09 +0200, Andrew Lunn wrote:
> On Tue, Mar 28, 2017 at 11:49:50AM +1100, Benjamin Herrenschmidt wrote:
> > Hi !
> > 
> > I noticed that flow control isn't being enabled on a system I'm
> > working on by default. I've tracked it down to two things:
> > 
> >  - The realtec.c PHY driver doesn't have Pause or Asym_Pause in
> > its exposed capabilities. This is in part because PHY_GBIT_FEATURES
> > does not include SUPPORTED_Pause and SUPPORTED_Asym_Pause. Is there
> > a specific reason for that ?
> 
> Hi Ben
> 
> It is worth reading Documentation/networking/phy.txt
> 
> The MAC should set SUPPORTED_Pause and SUPPORTED_Asym_Pause if the MAC
> supports these features. The PHY will then negotiate them.

Ok. I had added them but hit the other issue with the 1000bT  style
pause.

Cheers,
Ben.

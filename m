From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 03:09:40 +0200
Message-ID: <20170328010940.GG25549@lunn.ch>
References: <1490662190.3177.91.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36135 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753613AbdC1BKW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 21:10:22 -0400
Content-Disposition: inline
In-Reply-To: <1490662190.3177.91.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 11:49:50AM +1100, Benjamin Herrenschmidt wrote:
> Hi !
> 
> I noticed that flow control isn't being enabled on a system I'm
> working on by default. I've tracked it down to two things:
> 
>  - The realtec.c PHY driver doesn't have Pause or Asym_Pause in
> its exposed capabilities. This is in part because PHY_GBIT_FEATURES
> does not include SUPPORTED_Pause and SUPPORTED_Asym_Pause. Is there
> a specific reason for that ?

Hi Ben

It is worth reading Documentation/networking/phy.txt

The MAC should set SUPPORTED_Pause and SUPPORTED_Asym_Pause if the MAC
supports these features. The PHY will then negotiate them.

	 Andrew

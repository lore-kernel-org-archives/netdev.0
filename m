From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: PHY down?
Date: Tue, 2 Aug 2011 14:24:04 +0200
Message-ID: <OFEC77B7FA.1BCB17E8-ONC12578E0.0043754B-C12578E0.00441F36@transmode.se>
References: <OF6D5A2ABF.61D9AA63-ONC12578E0.00335EE4-C12578E0.0033AE22@transmode.se> <1312282868.2591.68.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:37986 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178Ab1HBMYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 08:24:08 -0400
In-Reply-To: <1312282868.2591.68.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote on 2011/08/02 13:01:08:
>
> On Tue, 2011-08-02 at 11:24 +0200, Joakim Tjernlund wrote:
> > I must be missing something obvious but I cannot find how
> > to bring eth0's PHY down (link down) from user space.
> > Tried various settings with ethtool and ifconfig eth0 down but it didn't help.
>
> If you configure an interface down, and if the interface is not used for
> remote management, then some drivers will turn the PHY off.  But there
> is no general way to control this explicitly.

OK, when to stop the PHY doesn't seem standardized. Seem logical to me
to also turn off the PHY when interface is configured down. Perhaps this could
be agreed upon?
What does remote management mean? How do I identify if the I/F is used for remote management?

 Jocke

>
> Ben.


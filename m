From: Simon Farnsworth <simon@farnz.org.uk>
Subject: Re: [RFC] net: allow FEC driver to not have attached PHY
Date: Thu, 07 Oct 2010 14:28:08 +0100
Message-ID: <i8kht9$obm$1@dough.gmane.org>
References: <201010070350.o973oGFE026910@goober.internal.moreton.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:55547 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755499Ab0JGNfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 09:35:19 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1P3qcu-0007fK-RM
	for netdev@vger.kernel.org; Thu, 07 Oct 2010 15:35:16 +0200
Received: from host217-35-101-6.in-addr.btopenworld.com ([217.35.101.6])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 15:35:16 +0200
Received: from simon by host217-35-101-6.in-addr.btopenworld.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 15:35:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg Ungerer wrote:

> 
> Hi All,
> 
> I have a board with a ColdFire SoC on it with the built-in FEC
> ethernet module. On this hardware the FEC eth output is directly
> attached to a RTL8305 4-port 10/100 switch. There is no conventional
> PHY, the FEC output is direct into the uplink port of the switch
> chip.
> 
> This setup doesn't work after the FEC code was switch to using
> phylib. The driver used to have code to bypass phy detection/setup
> for this particular board. The phylib probe finds nothing, and of
> course sets a no-link condition.
> 
> So, what is the cleanest way to support this?
> 
Is there anything that stops you using the fixed MDIO support in phylib 
(CONFIG_FIXED_PHY)? It seems to me to be intended for this sort of 
situation.

-- 
Simon


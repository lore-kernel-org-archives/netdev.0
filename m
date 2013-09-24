From: Gary Thomas <gary@mlbassoc.com>
Subject: SMSC 9303 support
Date: Tue, 24 Sep 2013 06:21:42 -0600
Message-ID: <524183D6.6040801@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mlbassoc.com ([65.100.170.105]:37617 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3IXMcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 08:32:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need to support the SMSC9303 in an embedded system.  I'm not
finding any [explicit] support for this device in the latest
mainline kernel.  Did I miss something?

To be clear, the SMSC9303 is a 3-port managed ethernet switch
capable of supporting 802.1D/802.1Q directly. This switch is
driven by a single MAC via MII/RMII and exposes the other two
ports via physical PHYs.  What I need it to do is behave like
two external, separate devices.  I was thinking that what I need
to do is treat these as VLAN devices since the switch can manage
the routing.

Does this seem like a reasonable approach?
How do I "hook up" my normal ethernet driver to it?  To the hardware
it just looks like any other MII/RMII PHY.  The device is managed
separately via I2C.  I can have that set up separately if necessary.

Thanks for any pointers/ideas

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------

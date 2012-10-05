From: James Kosin <jkosin@intcomgrp.com>
Subject: EG20T and Micrel KSZ9021 Gigabit Ethernet
Date: Fri, 5 Oct 2012 15:10:26 -0400
Message-ID: <506F30A2.500@intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: James Kosin <jkosin@intcomgrp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server104.appriver.com ([207.97.242.187]:3037 "EHLO
	server104.appriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756760Ab2JETKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 15:10:37 -0400
Received: from [216.54.13.100] (HELO MAILSRV2010.intcomgrp.com)
  by server104.appriver.com (CommuniGate Pro SMTP 5.4.4)
  with ESMTPS id 7219757 for netdev@vger.kernel.org; Fri, 05 Oct 2012 15:10:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anyone,

I'm using a Congatec QA6 Intel Atom board and need help getting the
onboard Micrel Ethernet PHY working correctly.
I've downloaded the latest stable kernel 3.5.5 from kernel.org, and
attempted to configure everything for the Debian platform I'm running
on.  Only problems are (1) the Ethernet PHY seems to be using pch_gbe
which seems to track back to an oki-semi directory under
drivers/net/ethernet ...
I'm tempted to reconfigure to remove that; but, am afraid that there is
no other driver for the network.  The only other set of drivers that
seem to be related are for the intel directory; but, these seem to be
intel specific.  I don't see support for this combination.

Anyone have an idea where I need to start?

PS:  Please reply to ALL when replying, I'm not a member of this list.

Thanks,
James

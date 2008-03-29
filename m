From: "Randy Macleod" <macleodr@nortel.com>
Subject: gianfar: multiqueue, vlan pbits -> qos?
Date: Sat, 29 Mar 2008 15:47:25 -0400
Message-ID: <47EE9CCD.8080304@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:40759 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168AbYC2Tsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 15:48:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Netdevers...

  I'm looking into extending the gianfar driver to
make use of multiple rx (and maybe tx) queues.
I've started to read the gianfar source, the Freescale docs and netdev.

Has anyone done this already?

My interest is in LAN network QOS,
primarily selective discard under overload.
I'm thinking that I'll create several vlans in my
network and do a strict vlan priority bit based servicing.

I'm also poking at the multi-queue work that has been
done and wondering how that might fit into a solution.
I haven't read the e1000 multiqueue driver yet...

Any tips, flames or code?

Thanks,
// Randy


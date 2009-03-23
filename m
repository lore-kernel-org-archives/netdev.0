From: Henning Rogge <hrogge@googlemail.com>
Subject: Linux kernel support for mesh network multicast routing
Date: Mon, 23 Mar 2009 09:23:05 +0100
Message-ID: <200903230923.05372.hrogge@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:58697 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbZCWIXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 04:23:09 -0400
Received: by ewy9 with SMTP id 9so1502008ewy.37
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 01:23:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm Henning Rogge, one of the programmers of the OLSR.org routing daemon.
OLSR is a proactive mesh net protocoll and our implementation is used mostly 
on small routers or embedded hardware.

At the moment OLSR.org does only support unicast routing (by setting routes in 
the linux kernel to do the hop-by-hop forwarding), but we would like to add 
the ability to use multicast too. OLSR is a proactive routing protocol, so 
each routing daemon has information about the whole network topology.

Most mesh networks use wireless links, so we don't have well defined broadcast 
interfaces and often have to retransmit incoming packages back through the 
same interface.

Does the linux kernel support setting up multicast forwarding rules like this 
so we could create multicast trees by the routing daemon and let the kernel 
forward the packages (and drop duplicates) ?

Henning Rogge

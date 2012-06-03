From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Generic user-space routing library -- need collaborator
Date: Sun, 03 Jun 2012 13:39:24 -0600
Message-ID: <4FCBBD6C.8020904@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:39914 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754569Ab2FCTxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2012 15:53:24 -0400
Received: from macbook.redfish-solutions.com ([192.168.1.17])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.5/8.14.5) with ESMTP id q53JdPYf013079
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 3 Jun 2012 13:39:25 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I'm working on adding a few more portability classes to Poco (a multi-platform C++ toolkit) and wanted to add a Net::Routing class for examining and manipulating the routing tables.

The C++ would just be convenience wrappers around a core C library that handles the netlink semantics. I've looked at libmnl and it's handy, but I need a higher level of abstraction (for instance, parsing an RTA_NETMASK for IPv6 is anything but well-documented).

I'm running into the limits of my linux-specific knowledge, though. I can get a specific route, but not the non-specific (default) route. Unless I'm doing something wrong (and I may be), the only way to get the default route seems to be to either get a route to a host you know will never be in your routing table, or else to dump the entire table and grep it out.

Not sure if that's a shortcoming in the rtnetlink API or my being an idiot.

Maybe both.

Anyway, if anyone can walk me through parsing some of the more esoteric routing permutations (like 6to4 tunnels, etc) I'd appreciate their contacting me out-of-band.

Thanks,

-Philip

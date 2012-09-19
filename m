From: Chad Gray <chad938@hotmail.com>
Subject: Netfilter lacks ability to filter packets via Application-origin
Date: Wed, 19 Sep 2012 15:40:40 -0400
Message-ID: <COL002-W12C33BCBEB56AC8ADFF6B0F39B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from col0-omc1-s5.col0.hotmail.com ([65.55.34.15]:63237 "EHLO
	col0-omc1-s5.col0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751000Ab2ISTkl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 15:40:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users need the ability for Linux firewall to filter packets based on what
Application they are originating from. This ability is present in Mac and
Windows firewalls, but not Linux.

For example, users would like ability to open Port 80 for Firefox, but keep
Port 80 closed for other applications.

This ability enhances Privacy & Security of the user but also helps to better
inform the user about the comings and goings of internet traffic and what
application/s are causing the traffic.

https://bugzilla.kernel.org/show_bug.cgi?id=47531 		 	   		  
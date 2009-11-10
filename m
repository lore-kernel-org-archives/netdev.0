From: "Chris Friesen" <cfriesen@nortel.com>
Subject: sunrpc port allocation and IANA reserved list
Date: Tue, 10 Nov 2009 11:43:23 -0600
Message-ID: <4AF9A63B.6010101@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:63325 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757353AbZKJRou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 12:44:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


By default sunrpc ports are allocated at random in the range 665-1023U.
 However, there are many ports within this range which have been
reserved by the IANA (and others like port 921 which are not formally
reserved but are "well-known").

Given that a userspace application can be stopped and restarted at any
time, and a sunrpc registration can happen at any time, what is the
expected mechanism to prevent the kernel from allocating a port for use
by sunrpc that reserved or well-known?

Apparently Redhat and Debian have distro-specific ways of dealing with
this, but is there a standard solution?  Should there be?

The current setup seems suboptimal.

Chris

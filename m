From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/5] LLC SOCK_DGRAM enhancements
Date: Tue, 23 May 2006 17:04:14 -0700
Message-ID: <20060524000414.052569000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7557 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932433AbWEXAFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:05:48 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I want to use AF_LLC and SOCK_DGRAM for handling Spanning
Tree Protocol packets in user space. The existing code doesn't work
and also doesn't support multicast. These basic problems and
add some cleanups.

--


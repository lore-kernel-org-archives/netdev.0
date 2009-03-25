From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH v2] ipv6: Fix bind conficts with v4-mapped addresses
Date: Tue, 24 Mar 2009 22:24:47 -0400
Message-ID: <1237947891-26825-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:5784 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630AbZCYCY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 22:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is an updated patch series to fix up bind() conflicts between v4-mapped
and IPv6 addresses.

These patches correct the following problems:
    1) Disallow binding of a v4-mapped address on a IPV6_V6ONLY socket.
    2) Allow IPv4 wildcards to bind at the same time as a native IPv6 address.
    3) Make v4-mapped bind()s consitant with IPv4 native binds.
    4) Fix conflict resolutions between v4-mapped addresses, v4 addresses, and v6
       addresses

Thanks
-vlad

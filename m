From: David Shwatrz <dshwatrz@gmail.com>
Subject: lookup in fib tables with NETLINK_FIB_LOOKUP
Date: Mon, 25 May 2009 13:44:19 +0300
Message-ID: <31436f4a0905250344md9c75fbud4540d48ce7f2a0d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: robert@robur.slu.se
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:12966 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788AbZEYKoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 06:44:20 -0400
Received: by fg-out-1718.google.com with SMTP id d23so627346fga.17
        for <netdev@vger.kernel.org>; Mon, 25 May 2009 03:44:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I would appreciate if someone can write a short and brief explanation about
the usage of  NETLINK_FIB_LOOKUP. It enables to perform a fib_lookup()
via netlink.
What's is its usage ? Are there any user space tools which use it ?
I grepped for "NETLINK_FIB_LOOKUP" under iproute2 source code and no hit.
Is there any difference between performing a lookup in the routing
tables (as "ip route ...")
and performing a lookup with NETLINK_FIB_LOOKUP?

The NETLINK_FIB_LOOKUP was added a time ago, by Robert Olsson in  2005.

see for example:http://www.mail-archive.com/netdev@vger.kernel.org/msg36395.html

(git commit 246955fe4c38bd706ae30e37c64892c94213775d)

Regards,
DS

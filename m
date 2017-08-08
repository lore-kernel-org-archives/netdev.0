From: Ondrej Zajicek <santiago@crfreenet.org>
Subject: Re: l3mdev: Support for sockets bound to enslaved device
Date: Tue, 8 Aug 2017 13:29:58 +0200
Message-ID: <20170808112958.ieexjwwgyp576kga@feanor.crfreenet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from varda.crfreenet.org ([81.92.145.160]:49626 "EHLO
        mail.crfreenet.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751927AbdHHLhD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 07:37:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

We noticed that TCP outgoing sockets that are bound to enslaved devices
by SO_BINDTODEVICE fail to connect, while they work when bound to vrf
device instead. We noticed similar behavior on ICMP (i.e. ping -I vrf0
worked, while ping -I eth0 does not if eth0 is enslaved to vrf0). On
the contrary, UDP outgoing sockets bound to enslaved devices worked
as expected. We tested that on Linux 4.9.30-2 from Debian.

I found your patchset 'Support for sockets bound to enslaved device'
( http://www.spinics.net/lists/netdev/msg448040.html ), which seems
to be related to the issue, but the description mentions services,
i.e. listening sockets. Does the patchset (or some other one) fixes
the issue also for outgoing sockets?

-- 
Elen sila lumenn' omentielvo

Ondrej 'Santiago' Zajicek (email: santiago@crfreenet.org)
OpenPGP encrypted e-mails preferred (KeyID 0x11DEADC3, wwwkeys.pgp.net)
"To err is human -- to blame it on a computer is even more so."

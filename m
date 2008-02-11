From: "Natalie Protasevich" <protasnb@gmail.com>
Subject: An ioctl to delete an ipv6 tunnel leads to a kernel panic
Date: Mon, 11 Feb 2008 12:49:12 -0800
Message-ID: <32209efe0802111249x16a6bbe0l4c152b3cf3aa0470@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:15586 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYBKUtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 15:49:19 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3911708fga.17
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 12:49:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This bug was reported to bugzilla.kernel.org:

http://bugzilla.kernel.org/show_bug.cgi?id=8895

Hardware Environment:  user mode linux and vmware
Software Environment:   an evolution of mip6d (ip mobility daemon)
Problem Description:     The mip6d HA was modified to make a
redondancy evolution, when an HA is interrupted, the other takes over,
this leads to some
creation/deletion of routes and tunnels.
Note: The HA ip address known by the mobile (MR) stays the same, the
slave HA takes it with an override neighbor advertisement message. So
the tunnel between
the mobile router and the HA(s) keep the same end adresses.
The problem occurs when a Ctrl C is done on the master HA, the slave
takes over but sometimes, the master gets a kernel panic.


Possible reason for this failure was identified and tested by the
submitter and several other reporters that ran into the same problem.
Can the patch be reviewed and pushed upstream if accepted (if the
problem hasn't been addressed already)?

Thanks,
--Natalie

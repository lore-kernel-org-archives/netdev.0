From: Alan Stern <stern@rowland.harvard.edu>
Subject: Runtime power management for network interfaces
Date: Tue, 25 Jul 2006 11:59:52 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:2055 "HELO
	iolanthe.rowland.org") by vger.kernel.org with SMTP id S932398AbWGYP75
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 11:59:57 -0400
To: Network development list <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During a Power Management session at the Ottawa Linux Symposium, it was
generally agreed that network interface drivers ought to automatically
suspend their devices (if possible) whenever:

    (1) The interface is ifconfig'ed down, or

    (2) No link is available.

Presumably (1) should be easy enough to implement.  (2) might or might not
be feasible, depending on how much WOL support is available.  (It might
not be feasible at all for wireless networking.)  Still, there can be no
question that it would be a Good Thing for laptops to power-down their
ethernet controllers when the network cable is unplugged.

Has any progress been made in this direction?  If not, a natural approach 
would be to start with a reference implementation in one driver which 
could then be copied to other drivers.

Any suggestions?

Alan Stern


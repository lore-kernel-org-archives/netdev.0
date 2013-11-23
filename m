From: James Feeney <james@nurealm.net>
Subject: r8169 - it's dead jim
Date: Sat, 23 Nov 2013 12:46:00 -0700
Message-ID: <529105F8.9030901@nurealm.net>
Reply-To: james@nurealm.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Realtek and the Linux r8169 crew <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay-fo.embarq.synacor.com ([208.47.184.9]:60894 "EHLO
	mailrelay.embarq.synacor.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753034Ab3KWUGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 15:06:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey

Going from 3.12.0-1-ARCH to 3.12.1-1-ARCH, the r8169 module is having the "link
detect" problem again.

Initially, "ethtool -s <blah> autoneg off" gives "invalid argument".

"sudo mii-tool -R enp22s0" - Reset the MII to its default configuration - will
allow a 10Mb/s half duplex connection, with "autoneg off".

"ethtool -s <blah> autoneg off" then will work, after the "mii-tool -R <blah>".

After some time, Auto-negotiation will spontaneously go on, and a 100Mb/s full
duplex connection will come up, on a 1Gb/s interface.  Subsequent unplugging and
plugging the cable gives a 1Gb/s full duplex connection.

This problem has been recurring for so many years, I hope the solution is
something obvious, perhaps a recent change to the kernel?


Thanks
James

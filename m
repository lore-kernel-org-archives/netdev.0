From: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
Subject: Bonding problem
Date: Sun, 7 Aug 2011 15:00:30 +0300
Message-ID: <CANMAZFUibmkyfWP2TyjwV6wtox6LNry2Gh3AtXB2KHnhGF80rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: majordomo@vger.kernel.org, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47244 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab1HGMAc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2011 08:00:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In the kernel 2.6.39.3 ( /drivers/net/bond/bond_main.c).
In the function =A0=91bond_xmit_roundrobin=92
The code check if the bond is active via
=91bond_is_active_slave(slave)=92 Function call.
Which actually checks if the slave is backup or active
What is the meaning of slave being =A0backup in round robin mode?
Correct me if I wrong but in round robin every slave should send a
packet, regardless of being active or backup.

Thank you,
=A0 =A0 =A0 =A0 =A0 =A0Eduard

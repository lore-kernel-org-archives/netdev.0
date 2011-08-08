From: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
Subject: On line Bonding configuration change fails
Date: Mon, 8 Aug 2011 11:16:39 +0300
Message-ID: <CANMAZFV=k3Yxix45+QnJAHUwq6wzZO+k=fqs0s61OW0sRBX9uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51596 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1HHIQk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 04:16:40 -0400
Received: by wyg24 with SMTP id 24so610482wyg.19
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 01:16:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


My configuration is a follows:

=A0 =A0 =A0 =A0 =A0 =A0 =A0| eth0 -------------->
Ububntu | eth1 --------------> =A0 =A0Swith ------------> Other compute=
r

Scenario:
=95 change the bond mode to active/backup
=95 unplug some of the cable
=95 plug-in the unplugged cable
=95 change bond mode to round robin

I can see that only one eth1 is sending data. When I unplug it the ping=
 stops.

Is it a bug or some mis-configuration?

In the kernel ( /drivers/net/bond/bond_main.c).
In the function =A0=91bond_xmit_roundrobin
=92
The code check if the bond is active via
=91bond_is_active_slave(slave)=92 Function call.
Which actually checks if the slave is backup or active
What is the meaning of backup in round robin?
Correct me if I wrong but in round robin every slave should send a
packet, regardless of being active or backup.




Thank you,
Eduard

From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: New driver questions: Attansic L1 gigabit NIC
Date: Sun, 13 Aug 2006 19:11:42 -0500
Message-ID: <44DFBFBE.1070201@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf23aec.mail.bellsouth.net ([205.152.59.71]:53703 "EHLO
	imf23aec.mail.bellsouth.net") by vger.kernel.org with ESMTP
	id S1751756AbWHNALo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 20:11:44 -0400
Received: from ibm66aec.bellsouth.net ([70.152.106.237])
          by imf23aec.mail.bellsouth.net with ESMTP
          id <20060814001143.CEEC5233.imf23aec.mail.bellsouth.net@ibm66aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Sun, 13 Aug 2006 20:11:43 -0400
Received: from [192.168.1.3] (really [70.152.106.237])
          by ibm66aec.bellsouth.net with ESMTP
          id <20060814001143.UBRS828.ibm66aec.bellsouth.net@[192.168.1.3]>
          for <netdev@vger.kernel.org>; Sun, 13 Aug 2006 20:11:43 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I recently purchased an Asus M2V socket AM2 motherboard that comes with
an onboard Attansic L1 Gigabit Ethernet Controller.  The CD that came
with the motherboard contains GPL'd driver source for the NIC.  The
driver builds, installs, and functions cleanly in Fedora Core 5. Despite
the clear assertion of GPL licensing in the license file[1], an
accompanying readme file says:

     This driver is only supported as a loadable
     module at this time. Attansic is not supplying
     patches against the kernel source to allow for
     static linking of the driver.

I've read the LKML FAQ regarding new driver submissions, but it implies
that the submitter be willing to maintain the driver, which I'm not
qualified to do.  I haven't contacted Attansic to request a change to
the above support statement, because my past attempts to contact vendors
on matters of this tenor have been greeted with silence.

First question: Can anyone who purchases a device that ships with GPL'd
driver source code submit said source code for inclusion in the kernel?

Second question: If I'm not qualified to maintain the driver, what are
its prospects for inclusion in the kernel?  How does one go about
soliciting a maintainer?


[1] [root@osprey atl1]# head -n 15 license

"This software program is licensed subject to the GNU General Public
License (GPL). Version 2, June 1991, available at
<http://www.fsf.org/copyleft/gpl.html>"

GNU General Public License

Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
59 Temple Place - Suite 330, Boston, MA  02111-1307, USA

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

---
Thanks,
Jay


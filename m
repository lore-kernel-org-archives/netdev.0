From: speedy <speedy@3d-io.com>
Subject: [BUG REPORT, 2.6.22] e1000: detected tx unit hang
Date: Mon, 21 Apr 2008 22:52:27 +0200
Message-ID: <1071646044.20080421225227@3d-io.com>
Reply-To: speedy <speedy@3d-io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vwp1316.webpack.hosteurope.de ([87.230.105.72]:60067 "EHLO
	vwp1316.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752009AbYDUVR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Linux crew,

        I've just switched the

        Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 01)

        netword card to an NForce 2 based motherboard and after a day
        of work it got stuck with "detected tx unit hang" messages
        showing in the console.

        The card worked flawlessly under load in a different computer
        for two years now, under the same/similar Ubuntu operating system.

        Unfortunaltly, the EEPROM fix from

        http://e1000.sourceforge.net/doku.php?id=known_issues&DokuWiki=9502f399bc8cae1528c5e85d2bc423f6

        from is not working/applicable:

        root@backupserver:~# ./fixeep-82573-dspd.sh eth1
        No appropriate hardware found for this fixup
        root@backupserver:~#

        /var/log/messages:  http://87.230.23.147/messages.txt
        /proc/interrupts: http://87.230.23.147/proc_interrupts.txt
        lspci -vv: http://87.230.23.147/lspcivv.txt


        If more info is needed, let me know.

        Thanks!

        ps. I don't follow the lists so please keep me in CC:

-- 
Best regards,
 speedy                          mailto:speedy@3d-io.com


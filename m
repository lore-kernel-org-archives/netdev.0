From: "Avuton Olrich" <avuton@gmail.com>
Subject: atl1 card hibernation regression
Date: Sun, 1 Jun 2008 07:42:02 -0700
Message-ID: <3aa654a40806010742s7529b9fxe02d0204f329065b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Jay Cliburn" <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:62455 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbYFAOmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 10:42:04 -0400
Received: by yw-out-2324.google.com with SMTP id 9so305137ywe.1
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 07:42:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After resuming from hibernate, my network card refuses to get back
online. The bisection and much more information are below.

http://avuton.googlepages.com/network-hibernate-config.gz
http://avuton.googlepages.com/network-hibernate-cpuinfo
http://avuton.googlepages.com/network-hibernate-dmesg
http://avuton.googlepages.com/network-hibernate-ioports
http://avuton.googlepages.com/network-hibernate-lspci-vvv
http://avuton.googlepages.com/network-hibernate-modules
http://avuton.googlepages.com/network-hibernate-ver-linux
http://avuton.googlepages.com/network-hibernate-version

08e0f1dc8388b3e134c714672c59edc2a7059430 is first bad commit
commit 08e0f1dc8388b3e134c714672c59edc2a7059430
Author: Jay Cliburn <jacliburn@bellsouth.net>
Date:   Fri May 9 22:12:07 2008 -0500

    atl1: fix broken suspend and resume

    Fix atl1_suspend() and atl1_resume() so they actually work.  We'll use
    the suspend function for wake-on-lan in addition to just suspending.

    Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

:040000 040000 3f637343c4cf04bf6579699f9780677ba2ec6001
1836f1832ced72a7265085f0395695d2914130ba M      drivers
-- 
avuton
--
 "I've got a fever. And the only prescription is more cowbell." --
Christopher Walken

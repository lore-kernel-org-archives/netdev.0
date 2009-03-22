From: Jesper Krogh <jesper@krogh.cc>
Subject: Status update on Sun Neptune 10Gbit fibre using the NIU-driver.
Date: Sun, 22 Mar 2009 10:11:42 +0100
Message-ID: <49C600CE.70704@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:47095 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbZCVJLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2009 05:11:46 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id CE3AC3BF571
	for <netdev@vger.kernel.org>; Sun, 22 Mar 2009 10:11:43 +0100 (CET)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id K9J9CZvqTixy for <netdev@vger.kernel.org>;
	Sun, 22 Mar 2009 10:11:32 +0100 (CET)
Received: from [192.168.1.4] (unknown [90.184.13.46])
	by shrek.krogh.cc (Postfix) with ESMTP id 23D9D3BF500
	for <netdev@vger.kernel.org>; Sun, 22 Mar 2009 10:11:32 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Back in the 2.6.25/26-days .. (around 9 months ago) I had som stuggles 
getting both performance and stabillity out of a Sun Neptune 10Gbit NIC 
over fibre. The NIU driver blew up on the system under load but Matheos 
Worku send me an internal Sun driver (nxge) that performed fairly well. 
It peaked out around 800-850 MB/s .. it put a fairly high load on the
host system and peaked with over 300.000 cs/s (both numbers measured
with dstat).

Today I got around to tesing the NIU(2.6.27.20) driver again. Having
repeated the test I did last summer I couldn't get it to "blow up". But
instead of the ~500MB/s i got out of it last summer, it peaks at 940MB/s
now and the load on the host is nearly invisible (<2) .. cs rates less
than 10K mostly.

I'm not using any kind of Jumbo frames in the setup.

I'll keep it up on the niu-driver for now and report back if it
encounters any problems.

In the test .. I do dd over NFS, default exports, default mount options
.. dd have "bs" set to either 1M or to 512 (to try to stress the NFS
server). I have tried to put cpu-load in the NFS-server while running
the NFS-server and pushing some data around on them memory subsystem
while doing it.

This is just excellent..  (crossing fingers that it can beat the 180 
days of uptime the nxge-driver got).

Link to old struggles:
http://thread.gmane.org/gmane.linux.kernel/677545

Jesper
-- 
Jesper

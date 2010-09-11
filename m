From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [BUG] atl1 causes lockup/reboot on resume from STR
Date: Sat, 11 Sep 2010 15:12:09 +0200
Message-ID: <20100911131209.GA3756@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46224 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879Ab0IKNMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 09:12:18 -0400
Received: by wwb13 with SMTP id 13so1308569wwb.1
        for <netdev@vger.kernel.org>; Sat, 11 Sep 2010 06:12:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I'm having troubles with atl1 driver (notebook is an Asus F3Sa): during
the resume from S3 the machine either locks up or reboots.
However I was also able to get a (partial) stack trace involving
atl1_resume (the rest of the trace scrolled off screen) and a message
about a recursive fault, followed by a hard lock up.
If I rmmod atl1 before suspending, the machine comes back fine; I don't
known whether this is a regression or not, until recently the radeon
driver didn't survive S3 so I didn't even try suspending to RAM...
I'm currently running -git current (2.6.36-rc3-00396-gbe6200a), but I've
gone back till 2.6.32 without any succcess.
I've no idea on how to debug this, the machine does not have a serial
port (and netconsole obviously does not help)... help :)

Luca

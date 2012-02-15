From: Dongsoo Nathaniel Kim <dongsoo.kim@gmail.com>
Subject: About bnx2-mips-09-6.2.1b.fw (Broadcom ethernet) firmware
Date: Wed, 15 Feb 2012 14:26:26 +0900
Message-ID: <CAP+Vy9cSK7kWbfYGT566BshozaQ-NqH0UpeuXEErLRLMP9Tt0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:39235 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751870Ab2BOF0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 00:26:46 -0500
Received: by obcva7 with SMTP id va7so987333obc.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 21:26:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks,

I'm wondering if it is ok to send a patch which includes
bnx2-mips-09-6.2.1b.fw.ihex.

I'm working on other subsystem of kernel but since someday, my machine
has problem with vanilla kernel which has been turned up with a
ethernet firmware file missing.

According to the bnx2 driver, it includes a firmware which does not
exist in firmware directory yet. (thanks to someone gave me a hint
that I can find in linux-firmware tho)

My machine uses "NetXtreme II BCM5709 Gigabit Ethernet" which
definitely tries to use FW_MIPS_FILE_09 according to the driver.

Every time I pull kernel repository and test vanilla kernel, it comes
up with a network problem. (actually extremely irritating)

So I made a patch including ihex of firmware myself but I'm not sure
it is ok to send this patch (legal issues? I'm not with Broadcom..)

Please let me know if it is ok.

Cheers,

--
=
Dongsoo Nathaniel Kim
Linux kernel, media device S/W engineer / Ph.D Student
Dept. of Computer Science, KAIST
Real-time & Embedded Systems Lab.

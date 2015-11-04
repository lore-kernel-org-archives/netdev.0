From: Toby Corkindale <tjc@wintrmute.net>
Subject: Regression in bonding driver - devices without set_mac
Date: Wed, 4 Nov 2015 14:49:12 +1100
Message-ID: <CABEgq95FYdt86-KEgkarUr-9g_mHoesV6B7OtrFut4pBR0UGcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:33904 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbbKDDtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 22:49:13 -0500
Received: by ykdr3 with SMTP id r3so52058373ykd.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 19:49:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I've subscribed to this list to try and sort out a regression in the
bonding network driver.
I originally reported this in Dec 2014, as:
https://bugzilla.kernel.org/show_bug.cgi?id=89161

The bug is still present in the 4.2 Linux kernel.

If you look at the code, here:
https://github.com/torvalds/linux/commit/f54424412b6b2f64cae4d7c39d981ca14ce0052c

Then you see that the intention is for devices without set_mac support
to be supported. Although in older code they DID work, and that
ability died sometime near this commit. And has never returned since.

The code path in current kernels does allow devices through that block
of code, but it fails somewhere else -- the devices are not
successfully added as slaves, but the only error printed is the
warning about not supporting MAC address setting.

Is there anything I can do to try and sort this regression out, with you?

I can explain how to set up two virtual machines with PPPoE client and
server in order to test, if you like? Or I can try out patches and
give feedback.

Cheers
Toby

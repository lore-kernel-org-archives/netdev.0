From: Chris Ross <chris@compilednetworks.com>
Subject: user-to-kernel shared memory with net_device
Date: Mon, 19 Oct 2009 16:28:42 -0500
Message-ID: <17cd85320910191428p4ca8bc9lc865babb18f29b1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f171.google.com ([209.85.216.171]:51943 "EHLO
	mail-px0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757632AbZJSV2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 17:28:38 -0400
Received: by pxi1 with SMTP id 1so706417pxi.33
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 14:28:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a net_device driver that has a fairly large (1-2MB) set of
stats that a user space process needs to read from time to time. I had
assumed the optimal ipc mechanism would be shared memory. Now that I'm
getting around to implementation of this side of the project I'm
getting a bit stuck.

All of the mmap examples I can find seem to be for character devices.
Do I need a character device that implements mmap and proxies access
to the net_device's stats, or is there a way to mmap directly to a
net_device structure? Also, is this the excepted method when a
userspace process needs to read large tables from a driver?

thanks,

-chris

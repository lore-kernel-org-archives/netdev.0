From: Eugene <elubarsky@gmail.com>
Subject: drivers/net/usb/asix: bug in asix_get_wol
Date: Sun, 11 Dec 2011 12:02:21 +1100
Message-ID: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, grundler@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52357 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab1LKBCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 20:02:23 -0500
Received: by bkcjm19 with SMTP id jm19so312972bkc.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 17:02:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear kernel devs,

Thanks for the commit at
http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378,
It successfully stops my adapter from dying when wake-on-lan gets
enabled. However, I've noticed that it has broken asix_get_wol - the
lines

       if (opt & AX_MONITOR_LINK)
               wolinfo->wolopts |= WAKE_PHY;
       if (opt & AX_MONITOR_MAGIC)
               wolinfo->wolopts |= WAKE_MAGIC;

have been accidentally removed. The vendor driver has them, and I've
successfully tested a kernel with these lines included. The change is
too small for me to bother sending in a properly formatted patch...


Cheers,
Eugene

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 24 Mar 2017 07:17:50 -0700
Message-ID: <1490365070.9687.46.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1490318850-23252-1-git-send-email-gerg@linux-m68k.org>
         <1490331560.9687.42.camel@edumazet-glaptop3.roam.corp.google.com>
         <44b9bf7a-70e5-a5f7-53f0-4ea3205638f1@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, oneukum@suse.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Greg Ungerer <gerg@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35766 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935237AbdCXOSE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 10:18:04 -0400
In-Reply-To: <44b9bf7a-70e5-a5f7-53f0-4ea3205638f1@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-24 at 15:42 +1000, Greg Ungerer wrote:

> The usbnet core is used by a number of drivers. This patch only
> updates the qmi-wwan driver to use stats64. If you remove the
> dev->stats.rx_* updates all those other driver users will have
> no counts.

I see. Then I guess the u64 stuff could be done only if running 32bit
kernels. (The existing stats are using 'unsigned long' so are already
64bit wide on 64bit kernels)

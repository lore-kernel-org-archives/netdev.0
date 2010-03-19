From: Amit Uttamchandani <amit.uttam@gmail.com>
Subject: Handling receive packets with limited buffer space
Date: Fri, 19 Mar 2010 02:41:18 -0700
Message-ID: <20100319094118.GA30249@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f182.google.com ([209.85.210.182]:35757 "EHLO
	mail-yx0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab0CSJlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 05:41:22 -0400
Received: by yxe12 with SMTP id 12so535720yxe.33
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 02:41:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In my modified ethoc.c driver, I am using only one receive buffer
descriptor due to limited space. This works fairly well for small
packets (arp, pings, etc.).

However, doing a 'wget' and downloading a file causes lots of drops and
thus results in a terminated connection.

How do I go about dealing with this? I tried stopping the queue
(netif_stop_queue) while I'm processing the rx skb and then resuming it
once I'm done, but this did not seem to help.

Any ideas on this?

Thanks for any help.
Amit

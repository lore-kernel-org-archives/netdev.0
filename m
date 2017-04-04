From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4] net: usbnet: support 64bit stats
Date: Mon, 03 Apr 2017 19:09:54 -0700 (PDT)
Message-ID: <20170403.190954.1010280922207176855.davem@davemloft.net>
References: <1491198603-24160-1-git-send-email-gerg@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, oneukum@suse.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: gerg@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53228 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752410AbdDDCJ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 22:09:56 -0400
In-Reply-To: <1491198603-24160-1-git-send-email-gerg@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@linux-m68k.org>
Date: Mon,  3 Apr 2017 15:50:03 +1000

> Add support for the net stats64 counters to the usbnet core. With that
> in place put the hooks into every usbnet driver to use it.
> 
> This is a strait forward addition of 64bit counters for RX and TX packet
> and byte counts. It is done in the same style as for the other net drivers
> that support stats64. Note that the other stats fields remain as 32bit
> sized values (error counts, etc).
> 
> The motivation to add this is that it is not particularly difficult to
> get the RX and TX byte counts to wrap on 32bit platforms.
> 
> Signed-off-by: Greg Ungerer <gerg@linux-m68k.org>

Applied, thank you.

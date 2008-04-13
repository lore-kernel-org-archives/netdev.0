From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
   prior to interface-up
Date: Sun, 13 Apr 2008 10:06:52 +0200
Message-ID: <4801BF1C.30207@gmail.com>
References: <1207839617.4311.6.camel@compaq.thuisdomein> <4801A85F.8090906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, Jeff Garzik <jgarzik@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:41817 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbYDMICh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 04:02:37 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1072289fgb.17
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 01:02:36 -0700 (PDT)
In-Reply-To: <4801A85F.8090906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 04/13/2008 08:29 AM:
...

> I guess it should return -EADDRNOTAVAIL similar to eth_mac_addr()
> when validation fails.

I think an additional printk should really save some time in guessing
what's wrong and with which address, especially if the same config
works OK with earlier kernels.

Regards,
Jarek P.

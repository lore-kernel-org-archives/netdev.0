From: Ale Lampro <lampro.listas@gmail.com>
Subject: Configuring and using RIPngd
Date: Wed, 14 Aug 2013 12:02:35 +0200
Message-ID: <CAABrkZnM90XTS1jZt-ZMDZTAG5mFeu2T0_++K+3Xxx8USQa6jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f195.google.com ([209.85.220.195]:33858 "EHLO
	mail-vc0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab3HNKCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 06:02:36 -0400
Received: by mail-vc0-f195.google.com with SMTP id gd11so1609231vcb.2
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 03:02:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am new to the list and I am trying to achieve something that I think
should be relatively easy with RIPngd and Quagga, but I am new to all
this so I have some issues.

I have two computers connected by a Serial link. I use "tunslip" which
creates a slip connection between them and mounts a tap0 interface in
my ubuntu linux computer.
The other computer generates a Response RIPng message advertising
ADDR1 (ipv6 address) in a given moment, which arrives to the linux
computer by the tap0 interface.
What I would like to do is to run ripng in this computer so that it
adds ADDR1 to its routing table but I am not able to do it.

The configuration for zebra and ripngd are the following.
ripngd: http://pastebin.com/Y8GHkcDB (link to the conf file)
zebra: http://pastebin.com/ZEVRfLx0 (link to the conf file)

As I was not sure at all of how I should configure them I just reused
a few things that I found on the internet but I guess it may not be
enough.

I would really appreciate if someone could give me a hint with this.

Thanks a lot.

Best regards,

Alejandro

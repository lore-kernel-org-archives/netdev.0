From: Kfir Lavi <lavi.kfir@gmail.com>
Subject: tun.c non formal header protocol?
Date: Thu, 24 Feb 2011 20:37:32 +0200
Message-ID: <AANLkTikpkgiTRDJe0gxuXosp_uvg0gKM_c7GcvL+hhLm@mail.gmail.com>
References: <AANLkTin-PJs07ruhhbC5U0DmqFd-rP8Csorethz_1kes@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38670 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667Ab1BXSiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 13:38:02 -0500
Received: by yxs7 with SMTP id 7so399613yxs.19
        for <netdev@vger.kernel.org>; Thu, 24 Feb 2011 10:38:01 -0800 (PST)
In-Reply-To: <AANLkTin-PJs07ruhhbC5U0DmqFd-rP8Csorethz_1kes@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I would like to use custom protocol over tun/tap device.
I'm grabbing packets, and changing them, to deliver via tap,
to a listener that knows this custom protocol.
The custom protocol is just wrapping the packet with another
small header.
Is it possible to move custom packets via tun.c ?
Is it possible to have a hook, just before the receiver gets
the packet, and then modify the header of the packet, so
it will not disturb tun.c ?

Is there any other options having the power of Linux stack
and netfilter, and using this custom protocol.

I'm grabbing the packets to userspace using nfq, and then with
verdict I'm returning them to the tap device.

Thanks,
Kfir

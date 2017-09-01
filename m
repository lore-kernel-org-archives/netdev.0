From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: netdev watchdog enp1s0 (tg3): transmit queue 0 timed out
Date: Thu, 31 Aug 2017 23:36:47 -0700
Message-ID: <CACKFLi=TXmPpHt_XRECHS7OhyyEyWVi=jcps5FNpg01Kjw6vUw@mail.gmail.com>
References: <1504246208.2050.15.camel@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>
To: Frans van Berckel <fberckel@xs4all.nl>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36460 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdIAGgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 02:36:49 -0400
Received: by mail-oi0-f49.google.com with SMTP id t75so13819384oie.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:36:48 -0700 (PDT)
In-Reply-To: <1504246208.2050.15.camel@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 11:10 PM, Frans van Berckel <fberckel@xs4all.nl> wrote:
> Dear NetDev Team,
>
> I am new to this machine. On a marketplace website I
> bought a Dell PowerEdge sc1435. Booting a today's Fedora (or even a
> Debian) amd64 Live CD from usb, and goes all fine.
>
> [    0.000000] Linux version 4.11.8-300.fc26.x86_64 (mockbuild@bkernel0
> 2.phx2.fedoraproject.org) (gcc version 7.1.1 20170622 (Red Hat 7.1.1-
> 3) (GCC) ) #1 SMP Thu Jun 29 20:09:48 UTC 2017
>
> Until .. I plunged in the ethernet cable for the first time. I have got
> console output, what frightens me a bit. It's about the driver for
> bcm95721. This kernel does a DMA Status error. And next it's calling a
> watchdog for enp1s0 (tg3): transmit queue 0 timed out.
>
> [  237.169194] tg3 0000:01:00.0 enp1s0: Link is up at 1000 Mbps, full
> du
> plex
> [  237.169335] tg3 0000:01:00.0 enp1s0: Flow control is on for TX
> and
> on for RX
> [  237.169375] IPv6: ADDRCONF(NETDEV_CHANGE): enp1s0: link
> becomes
> ready
> [  243.683910] tg3 0000:01:00.0 enp1s0: DMA Status
> error.  Resetting
> chip.
> [  243.759610] hrtimer: interrupt took 9464192 ns
> [  245.317566] tg3 0000:01:00.0 enp1s0: 0x00000000: 0x165914e4,
> 0x00100406, 0x02000021, 0x00000010
>
> <snap> a long list of likely the same type of error codes.
>

Please post the entire register dump.

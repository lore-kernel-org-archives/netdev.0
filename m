From: Maksim Lin <maks@manichord.com>
Subject: Re: i217-LM boot wreckage
Date: Tue, 25 Mar 2014 13:41:37 +1100
Message-ID: <CA+ZDVGN5g3frxBoG1PLU4ZUEXGcTFOqMfgFrHWLCAiXBy3AXbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:50097 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaCYCli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 22:41:38 -0400
Received: by mail-vc0-f171.google.com with SMTP id lg15so6784667vcb.2
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 19:41:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Mar 2014, Ertman, DavidX M wrote:

> I have discovered the cause of this issue.  It is related to the
> change in the application of a Si errata workaround.
>
> I will be working on grok'ing the total impact of this issue and
> writing up the patch over the weekend and will have something pushed
> into our internal queue early next week.

Hi,

Not sure if its helpful to have another report, but I'm pretty sure I
am seeing the same thing on my Dell Latitude 7440 running 3.14.0-rc7
but with a slightly different card:

$ ethtool -i eth0
driver: e1000e
version: 2.3.2-k
firmware-version: 0.6-3
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes

and from lspci -v:

00:19.0 Ethernet controller: Intel Corporation Ethernet Connection
I218-LM (rev 04)
    Subsystem: Dell Device 05cb
    Flags: bus master, fast devsel, latency 0, IRQ 59
    Memory at f7e00000 (32-bit, non-prefetchable) [size=128K]
    Memory at f7e3c000 (32-bit, non-prefetchable) [size=4K]
    I/O ports at f080 [size=32]
    Capabilities: <access denied>
    Kernel driver in use: e1000e
    Kernel modules: e1000e

I can try testing patches if it helps too.

thanks,
Maks.

From: "Gideon D'souza" <gidisrael@gmail.com>
Subject: Newbie: trying to hack an RTL8101E driver
Date: Mon, 24 Feb 2014 02:39:19 +0530
Message-ID: <CAPNrq4wV=r6mM0i1=NZ+H-Y0ahF2Cr3xQNPRcLfuNyObp4aZqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So I've submitted some patches for some tiny ongoing refactoring.

In the hopes of moving to more _real_ work I've been snooping at the
ethernet drivers. I was especially curious about driver code that is
running  for my own hardware.

I found out with lshw that I'm running a Atheros QCA9565 / AR9565
Wireless Network Adapter and a  RTL8101E/RTL8102E NIC.

For the atheros drivers after much google-fun I came by this
wireless.kernel.org/en/users/Drivers/ath9k and (correct me if I'm
wrong) there isn't a datasheet for this (and generally atheros)
drivers? They've been rev-engg'd ?

I went on the the realtek driver, I found this article on writing a
realtek driver (http://linuxgazette.net/156/jangir.html) I also looked
at Linux Device Drivers, both are pretty old. I also started reading
Documentation/pci/*

**However** I want to learn to write a driver for some hardware I own,
so I can actually see it in action.

The 8139 datasheet seems a lot bigger than the 8101E sheet
(http://realtek.info/pdf/rtl8101e_datasheet_1.2.pdf) and still doesn't
make a lot of sense to me.

Questions:
> As a newbie when it comes to writing software for hardware, is trying to write a driver for my hardware as a exercise doable/possible/good
> Any thing more general purpose I should read about networking and drivers?
> Any good resources other updated resources out there on how to use a datasheet to write a driver?

Thanks so Much
Gideon

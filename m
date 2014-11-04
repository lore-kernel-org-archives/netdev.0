From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Tue, 4 Nov 2014 16:11:43 +0100
Message-ID: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org
To: Greg KH <greg@kroah.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:39931 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbaKDPLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 10:11:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wanted to understand what is going on the kernel-side when
connecting to the Internet via a Huawei E173 USB web-stick (3rd
Generation: UMTS / HSPA).

Especially the correlation between the diverse USB/NET kernel-drivers
and how the networking is setup.

I have tested a Ubuntu trusty kernel on my Ubuntu/precise system and
compared the configs to get the stuff run on 3.18-rc2+.
Beyond the "option" driver, I required usb_serial / usb_wwan to be
activated and some more ("cde-ether" or sth. sound similiar...).
( Currently, I am not sitting (it's a Windows machine) in front of my
machine, so I cannot send you my latest kernel-config. )

As usually I looked into Documentation directory.
So, my 1st question where do I get some informations in general on
this topic - usb [1] or net subdirectory (seen from kernel-side)?
I found a usb-serial kernel-doc [1].
( I have no Linux Git source so I cannot grep for patterns. )

The next mystery is what is network-manager doing in the background?
I have seen that modem-manager is invoked, but as said I would like to
understand the "internas" (means check the logs, turn on some
debugging kernel-space/user-space, etc.).

I am not sure but syncing with 3G network seems to take a while since
I really can connect to the Internet.

I am happy about some fruitful informations or web-links...

Thanks in advance.

Regards,
- Sedat -

[1] https://www.kernel.org/doc/Documentation/usb/usb-serial.txt

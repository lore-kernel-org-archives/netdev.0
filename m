From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] 3c509.c: call SET_NETDEV_DEV for all device types (ISA/ISAPnP/EISA)
Date: Fri, 26 Apr 2013 01:03:53 +0400
Message-ID: <51799A39.6070002@cogentembedded.com>
References: <1366921743-6440-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Matthew Whitehead <tedheadster@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:53602 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756707Ab3DYVFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 17:05:10 -0400
Received: by mail-lb0-f176.google.com with SMTP id y8so3135069lbh.7
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 14:05:08 -0700 (PDT)
In-Reply-To: <1366921743-6440-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-04-2013 0:29, Matthew Whitehead wrote:

> From: Matthew Whitehead <tedheadster@gmail.com>

> The venerable 3c509 driver only sets its device parent in one case, the ISAPnP one.
> It does this with the SET_NETDEV_DEV function. It should register with the device
> hierarchy in two additional cases: standard (non-PnP) ISA and EISA.

> - Currently they appear here:
> /sys/devices/virtual/net/eth0 (standard ISA)
> /sys/devices/virtual/net/eth1 (EISA)

> - Rather, they should instead be here:
> /sys/devices/isa/3c509.0/net/eth0 (standard ISA)
> /sys/devices/pci0000:00/0000:00:07.0/00:04/net/eth1 (EISA)

> Tested on ISA and EISA boards.

    That's good but you forgot to sign off, so the patch can't be applied.

    BTW, it seems that after almost 7 years I seem to have found a tester for 
my patch which lingered all this time in the Andrew Morton's tree! You've said 
you have EISA boards, how about testing my patch? Now if I could find Andrew 
Morton's tree... Andrew?
    The patch is for 3c59x.c however -- I've just realized the difference.
Just in case, here's the link to 2008 version of it:

http://marc.info/?l=linux-netdev&m=121744737806819

WBR, Sergei

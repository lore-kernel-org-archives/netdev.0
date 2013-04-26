From: Lance Lassetter <lancelassetter@gmail.com>
Subject: [lancelassetter@gmail.com: r8169 with 3.9.0-rc9]
Date: Fri, 26 Apr 2013 14:16:37 -0500
Message-ID: <20130426191635.GA26727@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:40280 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757499Ab3DZTQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 15:16:41 -0400
Received: by mail-yh0-f49.google.com with SMTP id i7so121985yha.36
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 12:16:41 -0700 (PDT)
Received: from gmail.com (99-95-76-71.lightspeed.nworla.sbcglobal.net. [99.95.76.71])
        by mx.google.com with ESMTPSA id m30sm5740542yhi.11.2013.04.26.12.16.39
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Apr 2013 12:16:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from logwatch...

this is a problem...

Kernel

22 Time(s): r8169 0000:03:00.0 p10p1: link down
21 Time(s): r8169 0000:03:00.0 p10p1: link up
26 Time(s): r8169 0000:04:09.0 p8p1: link down
25 Time(s): r8169 0000:04:09.0 p8p1: link up

----- Forwarded message from Lance Lassetter <lancelassetter@gmail.com>=
 -----

Date: Fri, 26 Apr 2013 08:23:02 -0500
=46rom: Lance Lassetter <lancelassetter@gmail.com>
To: netdev@vger.kernel.org
Subject: r8169 with 3.9.0-rc9
User-Agent: Mutt/1.5.21 (2010-09-15)

hello,

i've exhausted my efforts to resolve this so i am sending you this emai=
l in hopes you might shed some light on the problem.

i have an onboard r8169 and a secondary pcie r8169 chipset gigabit ethe=
rnet adapters.

the link keeps sputtering with constant kernel messages (dmesg) of "lin=
k up link down"

the variant of linux is fedora 18 with testing branch enabled and fedor=
a "vanilla" kernel with minimal fedora patchset taken from fedora vanil=
la kernel repos as instructed on the fedora wiki.

the reason for the development kernel is i hoped with this, this proble=
m would be resolved.

dmesg looks like:

[52857.473520] r8169 0000:03:00.0 p10p1: link down
[52859.763261] r8169 0000:03:00.0 p10p1: link up
[52859.771250] r8169 0000:04:09.0 p8p1: link up
[52917.512992] r8169 0000:04:09.0 p8p1: link down
[52917.534918] r8169 0000:03:00.0 p10p1: link down
[52919.846520] r8169 0000:04:09.0 p8p1: link up
[52919.850411] r8169 0000:03:00.0 p10p1: link up
[53977.329829] r8169 0000:03:00.0 p10p1: link down
[53979.798396] r8169 0000:03:00.0 p10p1: link up
[54087.331434] r8169 0000:03:00.0 p10p1: link down
[54089.730198] r8169 0000:03:00.0 p10p1: link up

etc....

the box serves as a network router so it is causing abundant network tr=
affic problems.

any debugging i could help you with, please let me know.=A0 also if the=
re is a possible solution, please let me know.

kind regards and i wish you the best,

lance lassetter

----- End forwarded message -----

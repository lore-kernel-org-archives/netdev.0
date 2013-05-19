From: Boian Bonev <bbonev@ipacct.com>
Subject: RFC EOIP Tunnel
Date: Sun, 19 May 2013 18:31:40 +0300
Message-ID: <CAD53P8CY9SFvsrhiZqpxT=P5PtjbqL4LG1tf3O8jpU0yrychUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f176.google.com ([209.85.210.176]:65165 "EHLO
	mail-ia0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab3ESPcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 11:32:11 -0400
Received: by mail-ia0-f176.google.com with SMTP id j3so4362104iae.21
        for <netdev@vger.kernel.org>; Sun, 19 May 2013 08:32:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

EOIP is a proprietary ethernet over IP tunneling protocol introduced
by MikroTik's commercial product RouterOS. It uses GRE as protocol id
but with non-standard header.

Unlike EtherIP (RFC 3378) that is documented but not used, EOIP is not
documented but used for transparent Layer2 over wireless links and in
providing Layer2 services through multiple management domain networks
where pure L2 is as hard as near to impossible.

Long story short: my primary motivation behind doing this work was to
reduce the number of points of failure in a Linux+RouterOS and many
RouterOS endpoints setup. Old RouterOS endpoints do not support any
standard ethernet tunneling (upgrading is not an option) while Linux
does not support the EOIP protocol. On the other hand RouterOS cannot
be as flexible as Linux can be for routing and magic.

Judging from the existence of at least two separate opensource
projects doing this tunneling in userspace
(https://github.com/katuma/eoip and
https://code.google.com/p/linux-eoip/) I believe that this will be
useful for people using Linux in networked setups.

Before going in technical details and submitting patches I want to
know opinions if this work is suitable for merging upstream or is
better to be kept as a side kernel patch project.

With best regards,
b.

ps. https://github.com/bbonev/eoip contains 3.2.x patches + somehow
working but quite crappy config tool

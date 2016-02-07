From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Factor out register bit twiddling in the Renesas Ethernet drivers
Date: Sun, 07 Feb 2016 22:29:36 +0300
Message-ID: <10945950.IO3b17qsSH@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36633 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511AbcBGT3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:29:40 -0500
Received: by mail-lb0-f177.google.com with SMTP id dx2so73273665lbd.3
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 11:29:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's a set of 2 patches against DaveM's 'net-next.git' repo. We factor out
the often repeated pattern of reading a register, AND'ing and/or OR'ing some
bits, and then writing the value back.

[1/2] ravb: factor out register bit twiddling code
[2/2] sh_eth: factor out register bit twiddling code

MBR, Sergei

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Renesas: read MAC address registers only once
Date: Sat, 05 Dec 2015 00:55:54 +0300
Message-ID: <10429393.qU4CxZ5nlj@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33874 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbbLDVz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 16:55:59 -0500
Received: by lbbcs9 with SMTP id cs9so28148615lbb.1
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 13:55:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's 2 patches against DaveM's 'net-next.git' repo. Here we optimize the
MAC address register reading (left over from a bootloader).

[1/2] ravb: read MAC address registers only once
[2/2] sh_eth: read MAC address registers only once

MBR, Sergei

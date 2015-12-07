From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/3] sh_eth: optimize MDIO code
Date: Tue, 08 Dec 2015 00:39:03 +0300
Message-ID: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36313 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932392AbbLGVjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 16:39:12 -0500
Received: by lfs39 with SMTP id 39so257354lfs.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 13:39:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's a set of 3 patches against DaveM's 'net-next.git' repo which gets rid
of ~35 LoCs in the MDIO bitbang methods.

[1/3] sh_eth: remove mask fields from 'struct bb_info'
[2/3] sh_eth: factor out common code from MDIO bitbang methods
[3/3] sh_eth: get rid of bb_{set|clr|read}()

MBR, Sergei

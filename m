From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: NULL pointer dereference in xt_register_target()
Date: Wed, 5 Sep 2012 23:43:51 +0800
Message-ID: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:32827 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758848Ab2IEPnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:43:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, folks,

The latest net-next tree can't boot due to a NULL ptr def
bug in the kernel, the full backtrack is:

http://img1.douban.com/view/photo/photo/public/p1697139550.jpg

the kernel .config file is:

http://pastebin.com/9YTnkqKN

I don't have time to look into the issue. If you need other info,
please let me know.

Thanks.

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some issues
Date: Wed, 12 Aug 2015 17:28:24 +0900
Message-ID: <20150812082824.GA13385@gmail.com>
References: <20150722131730.GA18037@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36038 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933803AbbHLI2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:28:30 -0400
Received: by pacrr5 with SMTP id rr5so9833369pac.3
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 01:28:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150722131730.GA18037@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi,

It would be better if someone else is working on this.
Or could you help me out? It's a tough work for me.

Changes from RFC:
  * remove netlink_skb_zerocopy()
    I made a big mistake, and ``len <= skb_tailroom(to)'' for mmaped
    skb is always true in nfqnl_build_packet_message()

  * copy portid in netlink_skb_copy()
    for netlink_lookup() in __netlink_dump_start()

From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v4 0/4] rtnetlink: preparation patches for further rtnl lock pushdown/removal
Date: Tue, 26 Sep 2017 13:58:39 +0200
Message-ID: <20170926115843.12013-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58786 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S936361AbdIZL60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 07:58:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches split large rtnl_fill_ifinfo into smaller chunks
to better see which parts

1. require rtnl
2. do not require it at all
3. rely on rtnl locking now but could be converted

Changes since v3:

I dropped the 'ifalias' patch, I have a change to decouple ifalias and
rtnl mutex, I will send it once this series has been merged.

From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 0/7] ethtool: misc fixes for Coverity issues
Date: Fri, 30 Sep 2016 15:56:14 -0400
Message-ID: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38659 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbcI3UAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I requested a Coverity scan of the current ethtool sources. There
weren't many issues identified, but it was non-zero.

Most/all of the resource leak issues can be explained away as
unimportant due to the fact that ethtool invocations are short-term
processes. Nevertheless, I prefer to have those issues "fixed" both
to avoid them as distractions and just to promote better coding
practices overall.

These are "fresh off the press" -- I'll re-review them again before
applying and pushing them. I appreciate any extra eyeballs that can
review them as well.

John

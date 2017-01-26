From: Stephen Hemminger <stephen@networkplumber.org>
Subject: netvsc NAPI patch process
Date: Thu, 26 Jan 2017 10:04:05 -0800
Message-ID: <20170126100405.0eac2dea@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, "K. Y. Srinivasan" <kys@microsoft.com>,
        Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34690 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754140AbdAZSEN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:04:13 -0500
Received: by mail-pg0-f41.google.com with SMTP id 14so74167891pgg.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:04:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a working set of patches to enable NAPI in the netvsc driver.
The problem is that it requires a set of patches to vmbus layer as well.
Since vmbus patches have been going through char-misc-next tree rather
than net-next, it is difficult to stage these.

How about if I send the vmbus patches through normal driver-devel upstream
and during the 4.10 merge window send the last 3 patches for NAPI for linux-net
tree to get into 4.10?

From: David VomLehn <vomlehn@texas.net>
Subject: Suggestions for new Ethernet driver?
Date: Mon, 24 Oct 2016 22:10:25 -0700
Message-ID: <20161025051025.GA27184@gracie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: Linux networking mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda6.aus1.datafoundry.com ([209.99.124.137]:42118 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758007AbcJYF2g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 01:28:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working with Aquantia to add a new 2.5/5 Gbps driver to the kernel.
It looks like it's going to one of the biggest drivers in
drivers/net/ethernet. The team that developed the driver is new to
kernel development processes, but are working to make it
checkpatch-clean and addressing sparse issues. Right now we're working
to split the code into small chunks for review. The sequence of patches
first targets basic functionality, then adding a feature at a time. Still,
it's going to be a lot of work to review.

Aquantia is committed to doing the work to add this to the mainline
kernel but it's clearly going to be a substantial amount of work not
only for them, but for reviewers. So, my question: what can we do to
make this process easy for the networking community in addition to the
basics that are already under way? I welcome any and all suggestions.

Thanks!

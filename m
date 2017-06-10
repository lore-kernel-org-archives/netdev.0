From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH iproute/master 0/3] lost mpls ip tunnel patches
Date: Fri,  9 Jun 2017 18:31:29 -0700
Message-ID: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        dsahern@gmail.com, Krister Johansen <kjlx@templeofstupid.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:56386 "EHLO
        homiemail-a48.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751608AbdFJBcQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 21:32:16 -0400
Received: from homiemail-a48.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTP id B28AD70D2B10
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:15 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTPSA id 790EB70D2B04
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
I'm a bit unsure of the decorum in this particular situation. Kernel
support for mpls/ip tunnels was integrated back in July of 2016.  At the
time, the author of that feature sent out a RFC patch for the iproute
support but never followed up on subsequent code review comments.

The kernel support got merged, but the iproute support never made it in.
I wanted to run some tests with these features.  In the process, I
tracked down the author's original patches, merged them into current
iproute, and attempted to address the comments from code reviewers.

I've attached an 'Original-Author' label to each commit, and have CC'd
him and the code reviewer on this patch.  If any part of this is
improper, please let me know and I'll respin accordingly.  Mostly, I
wanted to close the loop here so the mpls in ip tunnel support is usable
through iproute.

The original threads for the 2016 patch are here:

http://marc.info/?l=linux-netdev&m=146782946216005&w=2
http://marc.info/?l=linux-netdev&m=146782941615977&w=2
http://marc.info/?l=linux-netdev&m=146782947016007&w=2
http://marc.info/?l=linux-netdev&m=146782942915988&w=2

Thanks,

-K

Krister Johansen (3):
  iptunnel: document mode parameter for sit tunnels
  iptunnel: add support for mpls/ip to sit tunnels
  iptunnel: add support for mpls/ip to ipip tunnels

 include/utils.h       |  3 +++
 ip/link_iptnl.c       | 30 ++++++++++++++++++++++++++----
 ip/tunnel.c           |  3 +++
 man/man8/ip-link.8.in | 12 +++++++++++-
 4 files changed, 43 insertions(+), 5 deletions(-)

-- 
2.7.4

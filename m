From: Florian Westphal <fw@strlen.de>
Subject: [RFC 0/3] ipsec: flow cache removal
Date: Tue, 27 Sep 2016 18:05:20 +0200
Message-ID: <1474992323-11327-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53290 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932674AbcI0QFZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:05:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not apply these patches.

These are part of tests I made for the ipsec workshop at upcoming
netdev 1.2 and I wanted to post these before the conference.

Short version is that there appear to be no major scalability issues
anymore without flow cache.  Performance hit can be up to 30%
in my tests (with 64 byte packets), however without flow cache we
also avoid some undesirable effects when flow cache is constantly
overloaded.

Seems most of the extra cost is mainly because of extra xfrm dst
init/destruction (and not e.g. due to policy lookup).

Lets discuss more at the workshop.

Thanks,
Florian

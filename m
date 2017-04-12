From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Network driver "test suite"
Date: Wed, 12 Apr 2017 10:16:17 +1000
Message-ID: <1491956177.7236.34.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60983 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752327AbdDLAQY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 20:16:24 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3C0GIjY007232
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 19:16:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks !

Does anybody knows of an existing kind of automated "test suite" for a
network/ethernet driver ?

IE. Something we could run both on the "tested" driver and a cross-over 
"known good" peer (possibly the latter set to promisc & no offload for
proper analysis), that would out the driver through a whole bunch of
tests, such as verifying the checksum offload on a various combinations
of headers lenghts and encapsulation, vlan stuff, multicast filters,
etc... ?

I've hacking on a driver recently and ended up "manually" testing a
bunch of these things using a palette of tools (iperf, nuttcp, some
multicast hack I have around, etc... along with tcpdump) but it feels
like this is the kind of things that could be greatly automated.

Cheers,
Ben.

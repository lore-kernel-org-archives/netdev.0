From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 0/6] xfrm: policy: make policy backend const
Date: Tue,  7 Feb 2017 15:00:13 +0100
Message-ID: <20170207140019.20269-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56630 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754214AbdBGOB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:01:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

This series removes all places that need to write to the afinfo policy
backends.  This then allows us to make the structures const.

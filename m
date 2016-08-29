From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Have the fix for softirq landed???
Date: Mon, 29 Aug 2016 08:36:57 +0200
Message-ID: <20160829083657.6111c558@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750738AbcH2GhC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 02:37:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric and Paolo,

Back in May you discovered (IMHO) a serious bug in softirq.  It even got
covered by LWN.net[1]. I've looked at the most recent git tree (linus
and net-next), and cannot see any changes that fixes this.
What is the progress in this area?

LWN.net: "Threadable NAPI polling, softirqs, and proper fixes"
 [1] http://lwn.net/Articles/687617/

Eric's proposed fix: http://lwn.net/Articles/687631/

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

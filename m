From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: [BUG] via-rhine: NOHZ: local_softirq_pending 08
Date: Wed, 23 Jan 2013 20:08:29 -0400
Message-ID: <51007b84.03ab640a.1cde.fffff62a@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:44383 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab3AXAIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:08:38 -0500
Received: by mail-yh0-f50.google.com with SMTP id z12so1335209yhz.37
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 16:08:37 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

   While conducting some tests on a VT6105M card. I noticed this message:

kernel: [  160.311113] NOHZ: local_softirq_pending 08

I was able to reliably reproduce the error message by setting autoneg off and changing the interface speed from 100 to 10 with ethtool.

Regards,
Jamie Gloudon

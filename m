From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: TX vs RX pause frame question
Date: Sun, 26 Mar 2017 21:11:11 +1100
Message-ID: <1490523071.3177.56.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34064 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751277AbdCZKLc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Mar 2017 06:11:32 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v2QABNLC019858
        for <netdev@vger.kernel.org>; Sun, 26 Mar 2017 05:11:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi !

It's not 100% clear to me looking at various drivers what is
considered "rx_pause" and what is "tx_pause" (from the ethtool
terminology).

Is "rx_pause" about receiving pause frame to throttle the transmitter
or is it about sending pause frames when the receiver gets full ?

Thanks,
Ben.

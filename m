From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: net: macb: fail when there's no PHY
Date: Thu, 21 Sep 2017 14:59:05 -0500
Message-ID: <20170921195905.GA29873@grante>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:48824 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdIUT7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 15:59:10 -0400
Received: by mail-io0-f172.google.com with SMTP id n69so13467461ioi.5
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 12:59:10 -0700 (PDT)
Received: from grante (67-130-15-94.dia.static.qwest.net. [67.130.15.94])
        by smtp.gmail.com with ESMTPSA id 78sm1378230itz.12.2017.09.21.12.59.07
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 12:59:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several years back (circa 2.6.33) I had to hack up macb.c to work on
an at91 board that didn't have a PHY connected to the macb controller.
Now I might need to get a recent kernel version running on that board.

It looks like the macb driver still can't handle boards that don't
have a PHY.  Is that correct?

What's the right way to deal with this?

With the older macb driver, I ended up adding code to macb.c that
presented a "fake" PHY that discarded MDIO writes and returned some
hard-wired values for MDIO reads.  That seemed like a pretty ugly way
to deal with the situation, so I never bothered to submit a patch.

-- 
Grant Edwards
grant.b.edwards@gmail.com

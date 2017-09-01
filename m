From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3] gianfar: Tx flow control fix (adjust_link)
Date: Fri, 01 Sep 2017 10:15:38 -0700 (PDT)
Message-ID: <20170901.101538.1176427534027457129.davem@davemloft.net>
References: <1504258863-2058-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752197AbdIARPj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:15:39 -0400
In-Reply-To: <1504258863-2058-1-git-send-email-claudiu.manoil@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@nxp.com>
Date: Fri, 1 Sep 2017 12:41:00 +0300

> Fix a small blunder in the Tx pause frame settings, that
> went unnoticed in the tangled code of adjust_link().
> I followed up with a couple of simple refactoring patches,
> aiming to make adjust_link() more manageable.
> 
> (The last 2 patches may be postponed if they are too much
> for the current stage of net.)

You need to fix some things up here.

First, do not mix bug fixes with cleanups.  Refactoring is a cleanup.

Submit the bug fix for 'net' and then later you can submit the
cleanups for 'net-next'.

Second, do not CC: stable for networking bug fixes, instead explicitly
ask me to queue up the fix for -stable.

Third, you need to fix how you specify your Fixes tag, it must
be exactly:

Fixes: $(SHA1_ID) ("Commit header text.")

And no matter how long the line is, do not break it up.

Thank you.

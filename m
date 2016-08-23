From: David Miller <davem@davemloft.net>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 09:40:29 -0700 (PDT)
Message-ID: <20160823.094029.1244944495918162255.davem@davemloft.net>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avijitnsec@codeaurora.org, ben@decadent.org.uk,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: luis.henriques@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754596AbcHWQky (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 12:40:54 -0400
In-Reply-To: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luis Henriques <luis.henriques@canonical.com>
Date: Tue, 23 Aug 2016 14:41:07 +0100

> Digging through some old CVEs I came across this one that doesn't seem be
> in mainline.  Was there a good reason for not being sent upstream?  Maybe it was
> rejected for some reason and I failed to find the discussion.

Because the patch is completely bogus, and thus so is the CVE.

The variable initializer clears out the entire structure.

Until you can show compiler output from gcc that shows it not
initializing the structure I will not apply this patch because I know
that it faithfully does.

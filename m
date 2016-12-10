From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 v3] net: qcom/emac: simplify support for different
 SOCs
Date: Fri, 09 Dec 2016 21:06:16 -0500 (EST)
Message-ID: <20161209.210616.736366493501564578.davem@davemloft.net>
References: <1481225061-30962-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alokc@codeaurora.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbcLJCGT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 21:06:19 -0500
In-Reply-To: <1481225061-30962-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu,  8 Dec 2016 13:24:19 -0600

> On SOCs that have the Qualcomm EMAC network controller, the internal
> PHY block is always different.  Sometimes the differences are small, 
> sometimes it might be a completely different IP.  Either way, using version
> numbers to differentiate them and putting all of the init code in one
> file does not scale.
> 
> This patchset does two things:  The first breaks up the current code into
> different files, and the second patch adds support for a third SOC, the
> Qualcomm Technologies QDF2400 ARM Server SOC.

Series applied.

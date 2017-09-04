From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: qualcomm: rmnet: Fix comments on
 initial patchset
Date: Sun, 03 Sep 2017 21:27:31 -0700 (PDT)
Message-ID: <20170903.212731.1651031812138547466.davem@davemloft.net>
References: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753335AbdIDE1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 00:27:32 -0400
In-Reply-To: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Sat,  2 Sep 2017 23:30:40 -0600

> This series fixes the comments from Dan on the first patch series.
> 
> Fixes a memory corruption which could occur if mux_id was higher than 32.
> Remove the RMNET_LOCAL_LOGICAL_ENDPOINT which is no longer used.
> Make a log message more useful.
> Combine __rmnet_set_endpoint_config() with rmnet_set_endpoint_config().
> Set the mux_id in rmnet_vnd_newlink().
> Set the ingress and egress data format directly in newlink.
> Implement ndo_get_iflink to find the real_dev.
> Rename the real_dev_info to port to make it similar to other drivers.
> 
> The conversion of rmnet_devices to a list and hash lookup will be sent
> as part of a seperate patch.

Series applied.

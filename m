From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next 0/6] sctp: add sender-side procedures for
 stream reconf asoc reset and add streams
Date: Thu, 09 Feb 2017 16:58:10 -0500 (EST)
Message-ID: <20170209.165810.1019732594616565226.davem@davemloft.net>
References: <cover.1486573727.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754175AbdBIV6a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:58:30 -0500
In-Reply-To: <cover.1486573727.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu,  9 Feb 2017 01:18:14 +0800

> Patch 4/6 is to implement sender-side procedures for the SSN/TSN Reset
> Request Parameter described in rfc6525 section 5.1.4, patch 3/6 is
> ahead of it to define a function to make the request chunk for it.
> 
> Patch 6/6 is to implement sender-side procedures for the Add Incoming
> and Outgoing Streams Request Parameter Request Parameter described in
> rfc6525 section 5.1.5 and 5.1.6, patch 5/6 is ahead of it to define a
> function to make the request chunk for it.
> 
> Patch 2/6 is a fix to recover streams states when it fails to send
> request and Patch 1/6 is to drop some unncessary __packed from some
> old structures.

Series applied with stray __packed reference removed from the commit
message of patch #3.

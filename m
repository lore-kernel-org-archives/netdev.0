From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/7] sctp: add receiver-side procedures for
 stream reconf ssn reset request chunk
Date: Sun, 19 Feb 2017 18:18:23 -0500 (EST)
Message-ID: <20170219.181823.4704280210611555.davem@davemloft.net>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdBSXS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 18:18:26 -0500
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 17 Feb 2017 12:45:36 +0800

> Patch 3/7 and 4/7 are to implement receiver-side procedures for the
> Outgoing and Incoming SSN Reset Request Parameter described in rfc6525
> section 5.2.2 and 5.2.3
> 
> Patch 1/7 and 2/7 are ahead of them to define some apis.
> 
> Patch 5/7-7/7 are to add the process of reconf chunk event in rx path.
> 
> Note that with this patchset, asoc->reconf_enable has no chance yet to
> be set, until the patch "sctp: add get and set sockopt for reconf_enable"
> is applied in the future. As we can not just enable it when sctp is not
> capable of processing reconf chunk yet.
 ...

Series applied, thanks.

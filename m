From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: mask tos for input route
Date: Sun, 26 Feb 2017 11:05:11 -0500 (EST)
Message-ID: <20170226.110511.987468399452857466.davem@davemloft.net>
References: <1488122075-23952-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdBZQF4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 11:05:56 -0500
In-Reply-To: <1488122075-23952-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 26 Feb 2017 17:14:35 +0200

> Restore the lost masking of TOS in input route code to
> allow ip rules to match it properly.
> 
> Problem [1] noticed by Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> [1] http://marc.info/?t=137331755300040&r=1&w=2
> 
> Fixes: 89aef8921bfb ("ipv4: Delete routing cache.")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Our TOS handling in the routing code is certainly more subtle than it
needs to be.

Applied and queued up for -stable.

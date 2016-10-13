From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/ptp: Fix kernel memory disclosure
Date: Thu, 13 Oct 2016 10:20:38 -0400 (EDT)
Message-ID: <20161013.102038.54956544698943812.davem@davemloft.net>
References: <1476190967-38256-1-git-send-email-vlad@tsyrklevich.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: vlad@tsyrklevich.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932422AbcJMOUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:20:43 -0400
In-Reply-To: <1476190967-38256-1-git-send-email-vlad@tsyrklevich.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Date: Tue, 11 Oct 2016 15:02:47 +0200

> The reserved field precise_offset->rsv is not cleared before being
> copied to user space, leaking kernel stack memory. Clear the struct
> before it's copied.
> 
> Signed-off-by: Vlad Tsyrklevich <vlad@tsyrklevich.net>

Applied and queued up for -stable, thanks Vlad.

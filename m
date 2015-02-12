From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Delete existing multicast MAC list
 before adding new
Date: Wed, 11 Feb 2015 19:43:34 -0800 (PST)
Message-ID: <20150211.194334.1487182178426500477.davem@davemloft.net>
References: <1423665924-4403-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688AbbBLDgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:36:32 -0500
In-Reply-To: <1423665924-4403-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Wed, 11 Feb 2015 09:45:24 -0500

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> Driver keeps adding multicast addresses without deleting removed MACs and
> worrying about adapters filter limit. This results into actual count of programmed
> multicast addresses get accumulated over the time and overruns the adapter's
> filter limit without putting device in ACCEPT_ALL_MULTI mode. This causes
> newly added multicast traffic to fail after the sequence of addition - deletion
> in certain pattern.
> 
> This issue is seen only when netdev's mcast list count is less than adapters
> mcast filter limit.
> 
> e.g. If adapters multicast filter limit is 38 per function
>      then following sequence would result in multicast traffic failure for
>      newly added MACs.
>      - add less than 38 multicast MACs
>      - remove previously added multicast MACs
>      - add new multicast MACs (less than 38)
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Applied.

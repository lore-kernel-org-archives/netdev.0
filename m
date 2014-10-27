From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] cxgb4 : DCBx fixes for apps/host lldp agents
Date: Mon, 27 Oct 2014 19:00:54 -0400 (EDT)
Message-ID: <20141027.190054.395800413881645288.davem@davemloft.net>
References: <1414100251-15702-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbaJ0XA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 19:00:56 -0400
In-Reply-To: <1414100251-15702-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu, 23 Oct 2014 14:37:29 -0700

> This patchset  contains some minor fixes for cxgb4 DCBx code. Chiefly, cxgb4 
> was not cleaning up any apps added to kernel app table when link was lost.
> Disabling DCBx in firmware would automatically set DCBx state to host-managed
> and enabled, we now wait for an explicit enable call from an lldp agent instead
> 
> First patch was originally sent to net-next, but considering it applies to
> correcting behaviour of code already in net, I think it qualifies as a bug fix.
> -Anish

Series applied, thanks Anish.

From: David Miller <davem@davemloft.net>
Subject: Re: [V3 PATCH 9/9] cxgb4vf: Chelsio FCoE offload driver submission
 (header compatibility fixes).
Date: Tue, 11 Sep 2012 13:33:21 -0400 (EDT)
Message-ID: <20120911.133321.282568248903907762.davem@davemloft.net>
References: <1347374347-3852-1-git-send-email-naresh@chelsio.com>
	<1347374347-3852-10-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org,
	chethan@chelsio.com
To: naresh@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab2IKRdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 13:33:25 -0400
In-Reply-To: <1347374347-3852-10-git-send-email-naresh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Naresh Kumar Inna <naresh@chelsio.com>
Date: Tue, 11 Sep 2012 20:09:07 +0530

> This patch contains minor fixes to make cxgb4vf driver work with the updates to
> shared firmware/hardware header files.
> 
> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>

You cannot submit a patch set that isn't bisectable, and in particular
create a situation that mid-way through your patch set things do not
build or operate correctly.

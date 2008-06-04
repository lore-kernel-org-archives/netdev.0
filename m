From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] SCTP: Start T3-RTX timer when fast retransmitting
 lowest TSN
Date: Wed, 04 Jun 2008 12:39:17 -0700 (PDT)
Message-ID: <20080604.123917.172467649.davem@davemloft.net>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
	<1212603951-24932-5-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755872AbYFDTjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:39:18 -0400
In-Reply-To: <1212603951-24932-5-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  4 Jun 2008 14:25:49 -0400

> When we are trying to fast retransmit the lowest outstanding TSN, we
> need to restart the T3-RTX timer, so that subsequent timeouts will
> correctly tag all the packets necessary for retransmissions.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Tested-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.

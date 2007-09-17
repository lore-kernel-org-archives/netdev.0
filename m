From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] SCTP: Implete SCTP-AUTH parameter processing
Date: Sun, 16 Sep 2007 19:32:23 -0700 (PDT)
Message-ID: <20070916.193223.94889648.davem@davemloft.net>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
	<11897954992330-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39473
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbXIQCcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 22:32:23 -0400
In-Reply-To: <11897954992330-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Sep 2007 14:44:55 -0400

> Implement processing for the CHUNKS, RANDOM, and HMAC parameters and
> deal with how this parameters are effected by association restarts.
> In particular, during unexpeted INIT processing, we need to reply with
> parameters from the original INIT chunk.  Also, after restart, we need
> to update the old association with new peer parameters and change the
> association shared keys.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24, thanks.

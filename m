From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/2] Alow tg3/bnx recevie full sized 802.1ad
 frames
Date: Wed, 01 Oct 2014 16:45:08 -0400 (EDT)
Message-ID: <20141001.164508.888781337332067925.davem@davemloft.net>
References: <1412120377-11125-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com,
	sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaJAUpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:45:10 -0400
In-Reply-To: <1412120377-11125-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 30 Sep 2014 19:39:35 -0400

> bnx2 and tg3 drivers drop packets that exceed device mtu and that
> do not have a vlan tag.  The idea is to catch ethernet frames
> that are too long.  This also ends up dropping 802.1ad tagged
> frames since the encapsulation protocol is different.
> We should not be dropping this packets.
> 
> v2:  rebased and consolidated tg3 and bnx patches.

Applied, thanks Vlad.

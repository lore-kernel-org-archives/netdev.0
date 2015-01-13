From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: fix typo of "unlikely" conditional in
 packet_snd
Date: Tue, 13 Jan 2015 14:26:04 -0500 (EST)
Message-ID: <20150113.142604.824938958848327187.davem@davemloft.net>
References: <1421176811-22594-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	hannes@stressinduktion.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbbAMT0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:26:07 -0500
In-Reply-To: <1421176811-22594-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 13 Jan 2015 14:20:11 -0500

> Change "unlikely(offset) < 0" to "unlikely(offset < 0)"...
> 
> Coverity: CID 1259984
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Should be fixed in the 'net' tree by:

commit 46d2cfb192b30d729aef064808ed5ece47cee369
Author: Christoph Jaeger <cj@linux.com>
Date:   Sun Jan 11 13:01:16 2015 -0500

    packet: bail out of packet_snd() if L2 header creation fails

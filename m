From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: fill in sane dump flag information
Date: Tue, 02 Jul 2013 00:16:20 -0700 (PDT)
Message-ID: <20130702.001620.827191367633835524.davem@davemloft.net>
References: <1372692200-31078-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, miris@broadcom.com, yuvalmin@broadcom.com,
	ariele@broadcom.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219Ab3GBHQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 03:16:21 -0400
In-Reply-To: <1372692200-31078-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Mon,  1 Jul 2013 17:23:20 +0200

> bnx2x did not set dump->version in its .get_dump_flag() method.
> Let's set it to BNX2X_DUMP_VERSION. It's not a particularly nice
> number (0x50acff01 currently), but at least it's something
> deterministic.
> 
> dump->flag should report the value previously set using ethtool -W.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied.

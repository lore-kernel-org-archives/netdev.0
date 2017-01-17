From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix byte order of vxlan-gpe port number
Date: Tue, 17 Jan 2017 15:24:28 -0500 (EST)
Message-ID: <20170117.152428.2276395361149194637.davem@davemloft.net>
References: <1484609878-7288-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdAQU0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:26:07 -0500
In-Reply-To: <1484609878-7288-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Mon, 16 Jan 2017 18:37:58 -0500

> vxlan->cfg.dst_port is in network byte order, so an htons()
> is needed here. Also reduced comment length to stay closer
> to 80 column width (still slightly over, however).
> 
> Fixes: e1e5314de08b ("vxlan: implement GPE")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied and queued up for -stable, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Bonding: Convert multiple netdev_info
 messages to netdev_dbg
Date: Thu, 29 Jun 2017 12:22:40 -0400 (EDT)
Message-ID: <20170629.122240.1600123631686282379.davem@davemloft.net>
References: <1498492186-4245-1-git-send-email-michael.j.dilmore@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, =andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        joe@perches.com
To: michael.j.dilmore@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752689AbdF2QWn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:22:43 -0400
In-Reply-To: <1498492186-4245-1-git-send-email-michael.j.dilmore@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael J Dilmore <michael.j.dilmore@gmail.com>
Date: Mon, 26 Jun 2017 16:49:46 +0100

> The bond_options.c file contains multiple netdev_info statements that clutter kernel output.
> This patch replaces all netdev_info with netdev_dbg and adds a netdev_dbg statement for the
> packets per slave parameter. Also fixes misalignment at line 467.
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Michael J Dilmore <michael.j.dilmore@gmail.com>

Applied.

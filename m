From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] atm: lanai: set error code when ioremap fails
Date: Mon, 05 Dec 2016 13:28:02 -0500 (EST)
Message-ID: <20161205.132802.1758015753602111376.davem@davemloft.net>
References: <1480767945-5676-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752879AbcLES2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:28:04 -0500
In-Reply-To: <1480767945-5676-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>
Date: Sat,  3 Dec 2016 20:25:45 +0800

> In function lanai_dev_open(), when the call to ioremap() fails, the
> value of return variable result is 0. 0 means no error in this context.
> This patch fixes the bug, assigning "-ENOMEM" to result when ioremap()
> returns a NULL pointer.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188791
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] atm: fix improper return value
Date: Mon, 05 Dec 2016 14:53:57 -0500 (EST)
Message-ID: <20161205.145357.1361147684146759738.davem@davemloft.net>
References: <1480830315-4924-1-git-send-email-bianpan201603@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bianpan2016@163.com
To: bianpan201603@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbcLETx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 14:53:58 -0500
In-Reply-To: <1480830315-4924-1-git-send-email-bianpan201603@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan201603@163.com>
Date: Sun,  4 Dec 2016 13:45:15 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> It returns variable "error" when ioremap_nocache() returns a NULL
> pointer. The value of "error" is 0 then, which will mislead the callers
> to believe that there is no error. This patch fixes the bug, returning
> "-ENOMEM".
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189021
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.

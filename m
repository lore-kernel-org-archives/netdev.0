From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] tcp: account for ts offset only if tsecr not
 zero
Date: Wed, 22 Feb 2017 16:34:29 -0500 (EST)
Message-ID: <20170222.163429.245664565583752528.davem@davemloft.net>
References: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
        <1487759036-2800-2-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, edumazet@google.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43822 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933593AbdBVVeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 16:34:36 -0500
In-Reply-To: <1487759036-2800-2-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Wed, 22 Feb 2017 13:23:56 +0300

> We can get SYN with zero tsecr, don't apply offset in this case.
> 
> Fixes: ee684b6f2830 ("tcp: send packets with a socket timestamp")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Applied.

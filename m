From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] driver: tun: Use new macro
 SOCK_IOC_TYPE instead of literal number 0x89
Date: Mon, 31 Oct 2016 10:57:34 -0400 (EDT)
Message-ID: <20161031.105734.1090205624340098305.davem@davemloft.net>
References: <1477530322-29021-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, edumazet@google.com, pabeni@redhat.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943769AbcJaO5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 10:57:40 -0400
In-Reply-To: <1477530322-29021-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Thu, 27 Oct 2016 09:05:22 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The current codes use _IOC_TYPE(cmd) == 0x89 to check if the cmd is one
> socket ioctl command like SIOCGIFHWADDR. But the literal number 0x89 may
> confuse readers. So create one macro SOCK_IOC_TYPE to enhance the readability.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.

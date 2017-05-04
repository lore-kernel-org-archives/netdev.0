From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: remove duplicate add_device_randomness() call
Date: Thu, 04 May 2017 11:13:02 -0400 (EDT)
Message-ID: <20170504.111302.1520073128399942830.davem@davemloft.net>
References: <1493869242-65468-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752412AbdEDPNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:13:04 -0400
In-Reply-To: <1493869242-65468-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Thu,  4 May 2017 11:40:42 +0800

> Since register_netdevice() already call add_device_randomness() and
> dev_set_mac_address() will call it after mac address change.
> It's not necessary to call at device UP.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

The net-next tree is closed, please resubmit this when the net-next
tree opens back up.

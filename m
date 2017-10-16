From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dev_ioctl: add missing NETDEV_CHANGE_TX_QUEUE_LEN
 event notification
Date: Mon, 16 Oct 2017 21:24:52 +0100 (WEST)
Message-ID: <20171016.212452.250697962684157736.davem@davemloft.net>
References: <c7cb587e601d7e27d126d79b6f06c873af1659bc.1508154195.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753222AbdJPUYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:24:54 -0400
In-Reply-To: <c7cb587e601d7e27d126d79b6f06c873af1659bc.1508154195.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Mon, 16 Oct 2017 19:43:15 +0800

> When changing dev tx_queue_len via netlink or net-sysfs,
> a NETDEV_CHANGE_TX_QUEUE_LEN event notification will be
> called.
> 
> But dev_ioctl missed this event notification, which could
> cause no userspace notification would be sent.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.

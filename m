From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] net: fix "queues" uevent between network namespaces
Date: Thu, 16 Jan 2014 08:19:12 -0800
Message-ID: <20140116161912.GB7476@kroah.com>
References: <1389864271-24212-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:52307 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbaAPQSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 11:18:50 -0500
Content-Disposition: inline
In-Reply-To: <1389864271-24212-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 05:24:31PM +0800, Chen Weilong wrote:
> From: Weilong Chen <chenweilong@huawei.com>
> 
> When I create a new namespace with 'ip netns add net0', or add/remove
> new links in a namespace with 'ip link add/delete type veth', rx/tx
> queues events can be got in all namespaces. That is because rx/tx queue
> ktypes do not have namespace support, and their kobj parents are setted to
> NULL. This patch is to fix it.
> 
> Reported-by: Libo Chen <chenlibo@huawei.com>
> Signed-off-by: Libo Chen <chenlibo@huawei.com>
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> ---
>  lib/kobject_uevent.c | 10 ++++++++--
>  net/core/net-sysfs.c | 26 ++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 2 deletions(-)

I can't test this, but it looks good to me:

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

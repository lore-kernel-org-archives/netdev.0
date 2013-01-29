From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V7 0/3] handle polling errors in vhost/vhost_net
Date: Tue, 29 Jan 2013 15:45:23 -0500 (EST)
Message-ID: <20130129.154523.725369676171401650.davem@davemloft.net>
References: <1359371119-10208-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359371119-10208-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 28 Jan 2013 19:05:16 +0800

> This is an update version of last version to fix the handling of polling errors
> in vhost/vhost_net.
> 
> Currently, vhost and vhost_net ignore polling errors which can lead kernel
> crashing when it tries to remove itself from waitqueue after the polling
> failure. Fix this by:
> 
> - examing the POLLERR when setting backend and report erros to userspace
> - let tun always add to waitqueue in .poll() after the queue is created even if
>   it was detached.

Series applied, thanks.

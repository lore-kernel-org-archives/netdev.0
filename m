From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3 2/2] macvtap: signal truncated packets
Date: Wed, 11 Dec 2013 15:26:33 -0500 (EST)
Message-ID: <20131211.152633.1259772133334006433.davem@davemloft.net>
References: <1386738514-1502-1-git-send-email-jasowang@redhat.com>
	<1386738514-1502-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vyasevich@gmail.com, wuzhy@linux.vnet.ibm.com, mst@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab3LKU0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:26:35 -0500
In-Reply-To: <1386738514-1502-2-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 11 Dec 2013 13:08:34 +0800

> macvtap_put_user() never return a value grater than iov length, this in fact
> bypasses the truncated checking in macvtap_recvmsg(). Fix this by always
> returning the size of packet plus the possible vlan header to let the trunca
> checking work.
> 
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Also applied and queued up for -stable, thanks.

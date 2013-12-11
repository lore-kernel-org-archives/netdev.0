From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3 1/2] tun: unbreak truncated packet signalling
Date: Wed, 11 Dec 2013 15:26:22 -0500 (EST)
Message-ID: <20131211.152622.282773097382499363.davem@davemloft.net>
References: <1386738514-1502-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com, mst@redhat.com, vyasevich@gmail.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab3LKU0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:26:25 -0500
In-Reply-To: <1386738514-1502-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 11 Dec 2013 13:08:33 +0800

> Commit 6680ec68eff47d36f67b4351bc9836fd6cba9532
> (tuntap: hardware vlan tx support) breaks the truncated packet signal by nev
> return a length greater than iov length in tun_put_user(). This patch fixes
> by always return the length of packet plus possible vlan header. Caller can
> detect the truncated packet by comparing the return value and the size of io
> length.
> 
> Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable.

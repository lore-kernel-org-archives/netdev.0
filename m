From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 2/2] tuntap: orphan frags before trying to
 set tx timestamp
Date: Thu, 05 Sep 2013 12:47:02 -0400 (EDT)
Message-ID: <20130905.124702.1612563649224221301.davem@davemloft.net>
References: <1378374840-39130-1-git-send-email-jasowang@redhat.com>
	<1378374840-39130-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, richardcochran@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378374840-39130-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu,  5 Sep 2013 17:54:00 +0800

> sock_tx_timestamp() will clear all zerocopy flags of skb which may lead the
> frags never to be orphaned. This will break guest to guest traffic when zerocopy
> is enabled. Fix this by orphaning the frags before trying to set tx time stamp.
> 
> The issue were introduced by commit eda297729171fe16bf34fe5b0419dfb69060f623
> (tun: Support software transmit time stamping).
> 
> Cc: Richard Cochran <richardcochran@gmail.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Acked-by: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.

I also queued both of these patches to -stable.

Thanks.

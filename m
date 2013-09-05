From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 1/2] tuntap: purge socket error queue on
 detach
Date: Thu, 05 Sep 2013 12:46:36 -0400 (EDT)
Message-ID: <20130905.124636.366480066838393015.davem@davemloft.net>
References: <1378374840-39130-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, richardcochran@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378374840-39130-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu,  5 Sep 2013 17:53:59 +0800

> Commit eda297729171fe16bf34fe5b0419dfb69060f623
> (tun: Support software transmit time stamping) will queue skbs into error queue
> when tx stamping is enabled. But it forgets to purge the error queue during
> detach. This patch fixes this.
> 
> Cc: Richard Cochran <richardcochran@gmail.com>
> Acked-by: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.

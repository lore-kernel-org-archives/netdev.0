From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] tuntap: orphan frags before trying to set
 tx timestamp
Date: Wed, 4 Sep 2013 17:57:38 +0200
Message-ID: <20130904155738.GC4194@netboy>
References: <1378269226-5969-1-git-send-email-jasowang@redhat.com>
 <1378269226-5969-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378269226-5969-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 04, 2013 at 12:33:46PM +0800, Jason Wang wrote:
> sock_tx_timestamp() will clear all zerocopy flags of skb which may lead the
> frags never to be orphaned. This will break guest to guest traffic when zerocopy
> is enabled. Fix this by orphaning the frags before trying to set tx time stamp.
> 
> The issue were introduced by commit eda297729171fe16bf34fe5b0419dfb69060f623
> (tun: Support software transmit time stamping).
> 
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>

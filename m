From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] tuntap: purge socket error queue on detach
Date: Wed, 4 Sep 2013 17:56:56 +0200
Message-ID: <20130904155656.GB4194@netboy>
References: <1378269226-5969-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378269226-5969-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 04, 2013 at 12:33:45PM +0800, Jason Wang wrote:
> Commit eda297729171fe16bf34fe5b0419dfb69060f623
> (tun: Support software transmit time stamping) will queue skbs into error queue
> when tx stamping is enabled. But it forgets to purge the error queue during
> detach. This patch fixes this.
> 
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>

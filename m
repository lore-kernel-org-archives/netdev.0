From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] netpoll: fix use after free
Date: Tue, 08 Jul 2014 20:51:18 -0700 (PDT)
Message-ID: <20140708.205118.498700090425113718.davem@davemloft.net>
References: <cover.1404857349.git.decot@googlers.com>
	<96b940137a50e5c387687bb4f57de8b0435a653f.1404857349.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, edumazet@google.com, amwang@redhat.com,
	antonio@meshcoding.com, jpirko@redhat.com
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <96b940137a50e5c387687bb4f57de8b0435a653f.1404857349.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Tue,  8 Jul 2014 15:14:41 -0700

> After a bonding master reclaims the netpoll info struct, slaves could
> still hold a pointer to the reclaimed data. This patch fixes it: as
> soon as netpoll_async_cleanup is called for a slave (eg. when
> un-enslaved), we make sure that this slave doesn't point to the data.
> 
> Signed-off-by: David Decotigny <decot@googlers.com>

Applied, thank you.

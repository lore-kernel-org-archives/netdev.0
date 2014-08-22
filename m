From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v3] hyperv: Increase the buffer length for
 netvsc_channel_cb()
Date: Fri, 22 Aug 2014 12:27:15 -0700 (PDT)
Message-ID: <20140822.122715.2235186075962103027.davem@davemloft.net>
References: <1408130299-50848-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408130299-50848-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri, 15 Aug 2014 19:18:19 +0000

> When the buffer is too small for a packet from VMBus, a bigger buffer will be
> allocated in netvsc_channel_cb() and retry reading the packet from VMBus.
> Increasing this buffer size will reduce the retry overhead.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: Dexuan Cui <decui@microsoft.com>

Applied, thanks.

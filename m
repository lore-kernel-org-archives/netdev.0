From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Fix the VLAN_TAG_PRESENT in netvsc_recv_callback()
Date: Mon, 17 Jun 2013 15:58:29 -0700 (PDT)
Message-ID: <20130617.155829.1565606302338817921.davem@davemloft.net>
References: <1371508609-22780-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371508609-22780-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon, 17 Jun 2013 15:36:49 -0700

> We should call __vlan_hwaccel_put_tag() only if the packet
> comes from vlan, otherwise VLAN_TAG_PRESENT will always be
> added.
> 
> Reported-by: Olaf Hering <olaf@aepfle.de>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.

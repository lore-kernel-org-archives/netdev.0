From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Fri, 19 Apr 2013 16:50:06 -0400 (EDT)
Message-ID: <20130419.165006.1200833792933507239.davem@davemloft.net>
References: <1366151150-14859-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366151150-14859-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 16 Apr 2013 15:25:50 -0700

> Fixed: warning: cast from pointer to integer of different size
> 
> The Hyper-V hosts always use 64 bit request id. The guests can have 32 or 64
> bit pointers which equal to the ulong type size. So we cast it to ulong type.
> And, assigning 32bit integer to 64 bit variable works fine.
> 
> The VMBus returns the same id in the completion packet. But the value has no
> effect on the host side.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Such build warning fixes are not appropriate for 'net' at this time, and
this patch does not apply to 'net-next', so I'm dropping this entirely.

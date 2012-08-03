From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/1] hyperv: Move wait completion msg code
 into rndis_filter_halt_device()
Date: Fri, 03 Aug 2012 16:52:12 -0700 (PDT)
Message-ID: <20120803.165212.106382119661240198.davem@davemloft.net>
References: <1344022338-3010-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344022338-3010-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri,  3 Aug 2012 12:32:18 -0700

> We need to wait for send_completion msg before put_rndis_request() at
> the end of rndis_filter_halt_device(). Otherwise, netvsc_send_completion()
> may reference freed memory which is overwritten, and cause panic.
> 
> Reported-by: Long Li <longli@microsoft.com>
> Reported-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

This is a bug fix, so applied to 'net'.  Please target your patches
properly.

Don't just be afraid that I'll reject the patch if you target it
at 'net', and therefore just target everything at 'net-next'.  That
is certainly worse.

From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Sat, 4 Mar 2006 14:20:30 -0500
Message-ID: <20060304192030.GA6510@kvack.org>
References: <20060303214036.11908.10499.stgit@gitlost.site> <20060303214220.11908.75517.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751990AbWCDTZj@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <20060303214220.11908.75517.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2006 at 01:42:20PM -0800, Chris Leech wrote:
> +void dma_async_device_unregister(struct dma_device* device)
> +{
...
> +	kref_put(&device->refcount, dma_async_device_cleanup);
> +	wait_for_completion(&device->done);
> +}

This looks like a bug: device is dereferenced after it is potentially 
freed.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.

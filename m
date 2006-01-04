From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] forcedeth: TSO fix for large buffers
Date: Tue, 3 Jan 2006 22:55:27 -0800
Message-ID: <20060103225527.0e7c4ac0.akpm@osdl.org>
References: <200512251451.jBPEpgNe018712@dbl.q-ag.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, aabdulla@nvidia.com, afu@fugmann.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751581AbWADG4M@vger.kernel.org>
To: Manfred Spraul <manfred@dbl.q-ag.de>
In-Reply-To: <200512251451.jBPEpgNe018712@dbl.q-ag.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Manfred Spraul <manfred@dbl.q-ag.de> wrote:
>
> This patch contains a bug fix for large buffers. Originally, if a tx 
>  buffer to be sent was larger then the maximum size of the tx descriptor,
> 
>  it would overwrite other control bits. In this patch, the buffer is 
>  split over multiple descriptors. Also, the fragments are now setup in 
>  forward order.
> 
>  Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
>  Rediffed against forcedeth 0.48
>  Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

I've assumed that this patch if From: Ayaz.   Please confirm.

If so, it should have had

	From: Ayaz Abdulla <aabdulla@nvidia.com>

at the top of the changlog, thanks.

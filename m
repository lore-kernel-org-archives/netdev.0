From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH RESEND] atl1: fix 4G memory corruption bug
Date: Thu, 22 May 2008 17:20:30 -0400
Message-ID: <4835E39E.90801@garzik.org>
References: <20080522220025.GA566@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jay Cliburn <jacliburn@bellsouth.net>, stable@kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762884AbYEVVVU@vger.kernel.org>
In-Reply-To: <20080522220025.GA566@martell.zuzino.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> 
> When using 4+ GB RAM and SWIOTLB is active, the driver corrupts
> memory by writing an skb after the relevant DMA page has been
> unmapped.  Although this doesn't happen when *not* using bounce
> buffers, clearing the pointer to the DMA page after unmapping
> it fixes the problem.
> 
> http://marc.info/?t=120861317000005&r=2&w=2
> 
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
> 
>  drivers/net/atlx/atl1.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

applied

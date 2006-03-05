From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 7/8] [I/OAT] Add a sysctl for tuning the I/OAT offloaded
 I/O threshold
Date: Sat, 4 Mar 2006 23:21:24 -0800
Message-ID: <20060304232124.621ba696.akpm@osdl.org>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	<20060303214234.11908.99495.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752154AbWCEHW6@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060303214234.11908.99495.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> Any socket recv of less than this ammount will not be offloaded
> 
> ...
>
> +int sysctl_tcp_dma_copybreak = NET_DMA_DEFAULT_COPYBREAK;

Is it appropriate that this tunable be kernel-wide, rather than more
finely-grained?

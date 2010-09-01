From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Wed, 1 Sep 2010 12:20:59 +0200
Message-ID: <20100901122059.5761802f@marrow.netinsight.se>
References: <20100831011348.GA11993@redhat.com>
	<20100831111052.31f22185@marrow.netinsight.se>
	<20100831172106.GC1844@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:1206 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752379Ab0IAKVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 06:21:04 -0400
In-Reply-To: <20100831172106.GC1844@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Aug 2010 13:21:07 -0400
Dave Jones <davej@redhat.com> wrote:

> On Tue, Aug 31, 2010 at 11:10:52AM +0200, Simon Kagstrom wrote:
>  > On Mon, 30 Aug 2010 21:13:49 -0400
>  > Dave Jones <davej@redhat.com> wrote:
>  > 
>  > > I installed the Fedora 14 alpha, which is based on 2.6.35.2, and hit
>  > > the following trace..
>  > > 
>  > > WARNING: at lib/dma-debug.c:811 check_unmap+0x212/0x59b()
>  > > Hardware name:  
>  > > via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x00000000194ba27e] [map size=66 bytes] [unmap size=182 bytes]
>  > 
>  > I can't reproduce it here, but does the patch below help for you?
> 
> It's looking good so far.  It's been up 30 minutes and hasn't triggered yet
> (normally it triggers very shortly after bootup)

Sounds good. I'll think a bit more about this and submit the patch
after that.

I'm not really an expert on the subject, but with skb_headlen(), the size
should be the same for pci_map_single and pci_unmap_single as far as I
can tell.

// Simon

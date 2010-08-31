From: Dave Jones <davej@redhat.com>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Tue, 31 Aug 2010 13:21:07 -0400
Message-ID: <20100831172106.GC1844@redhat.com>
References: <20100831011348.GA11993@redhat.com>
 <20100831111052.31f22185@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Simon Kagstrom <simon.kagstrom@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52503 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651Ab0HaRVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 13:21:18 -0400
Content-Disposition: inline
In-Reply-To: <20100831111052.31f22185@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 31, 2010 at 11:10:52AM +0200, Simon Kagstrom wrote:
 > On Mon, 30 Aug 2010 21:13:49 -0400
 > Dave Jones <davej@redhat.com> wrote:
 > 
 > > I installed the Fedora 14 alpha, which is based on 2.6.35.2, and hit
 > > the following trace..
 > > 
 > > WARNING: at lib/dma-debug.c:811 check_unmap+0x212/0x59b()
 > > Hardware name:  
 > > via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x00000000194ba27e] [map size=66 bytes] [unmap size=182 bytes]
 > 
 > I can't reproduce it here, but does the patch below help for you?

It's looking good so far.  It's been up 30 minutes and hasn't triggered yet
(normally it triggers very shortly after bootup)

	Dave

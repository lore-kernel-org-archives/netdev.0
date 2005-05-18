From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Tue, 17 May 2005 19:52:38 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0505171941340.21153@graphe.net>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
 <20050517190343.2e57fdd7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262064AbVERCxB@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050517190343.2e57fdd7.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 May 2005, Andrew Morton wrote:

> Christoph Lameter <christoph@graphe.net> wrote:
> >
> > NUMA awareness for the e1000 driver. Allocate transmit and receive buffers
> > on the node of the device.
> 
> Hast thou any benchmarking results?

Yes, your honor. Just a second .... The patch has been around for a long 
time.

No benchmarks results in my email archive. Would need to talk to some 
folks tomorrow and maybe we would have to run some new 
benchmarks.

> > -	txdr->buffer_info = vmalloc(size);
> > +	txdr->buffer_info = kmalloc_node(size, GFP_KERNEL, node);
> 
> How come that this is safe to do

Because physically contiguous memory is usually better than virtually 
contiguous memory? Any reason that physically contiguous memory will 
break the driver?

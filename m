From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Tue, 17 May 2005 19:03:43 -0700
Message-ID: <20050517190343.2e57fdd7.akpm@osdl.org>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@graphe.net> wrote:
>
> NUMA awareness for the e1000 driver. Allocate transmit and receive buffers
> on the node of the device.

Hast thou any benchmarking results?

> -	txdr->buffer_info = vmalloc(size);
> +	txdr->buffer_info = kmalloc_node(size, GFP_KERNEL, node);

How come this is safe to do?

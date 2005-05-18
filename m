From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Tue, 17 May 2005 21:27:48 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0505172125210.22920@graphe.net>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
 <20050517190343.2e57fdd7.akpm@osdl.org> <Pine.LNX.4.62.0505171941340.21153@graphe.net>
 <20050517.195703.104034854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        shai@scalex86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050517.195703.104034854.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 May 2005, David S. Miller wrote:

> > Because physically contiguous memory is usually better than virtually 
> > contiguous memory? Any reason that physically contiguous memory will 
> > break the driver?
> 
> The issue is whether size can end up being too large for
> kmalloc() to satisfy, whereas vmalloc() would be able to
> handle it.

Oww.. We need a NUMA aware vmalloc for this?  

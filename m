From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers for e1000
Date: Wed, 18 May 2005 08:55:39 -0700
Message-ID: <5fc59ff305051808558f1ce59@mail.gmail.com>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
	 <20050517190343.2e57fdd7.akpm@osdl.org>
	 <Pine.LNX.4.62.0505171941340.21153@graphe.net>
	 <20050517.195703.104034854.davem@davemloft.net>
	 <Pine.LNX.4.62.0505172125210.22920@graphe.net>
	 <20050517215845.2f87be2f.akpm@osdl.org>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Christoph Lameter <christoph@lameter.com>, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shai@scalex86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050517215845.2f87be2f.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 5/17/05, Andrew Morton <akpm@osdl.org> wrote:
> I think the e1000 driver is being a bit insane there.  I figure that
Do you mean insane to use vmalloc?

> sizeof(struct e1000_buffer) is 28 on 64-bit, so even with 4k pagesize we'll
> always succeed in being able to support a 32k/32 = 1024-entry Tx ring.
> 
> Is there any real-world reason for wanting larger ring sizes than that?
> 
> 
We have had cases where allocation of 32K of memory (via kmalloc) fails. 

ganesh.

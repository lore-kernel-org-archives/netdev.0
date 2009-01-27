From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ide/net: flip the order of SATA and network init
Date: Tue, 27 Jan 2009 14:26:38 -0800 (PST)
Message-ID: <20090127.142638.56529472.davem@davemloft.net>
References: <20090127141952.51785b4f@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-ide@vger.kernel.org, netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20090127141952.51785b4f@infradead.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 27 Jan 2009 14:19:52 -0800

> ide/net: flip the order of SATA and network init
> 
> this patch flips the order in which sata and network drivers are initialized.
> 
> SATA probing takes quite a bit of time, and with the asynchronous infrastructure
> other drivers that run after it can execute in parallel. Network drivers do tend
> to take some real time talking to the hardware, so running these later is
> a good thing (the sata probe then runs concurrent)
> 
> This saves about 15% of my kernels boot time.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

I have no problem with this:

Acked-by: David S. Miller <davem@davemloft.net>

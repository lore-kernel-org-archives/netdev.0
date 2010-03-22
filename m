From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] if_tunnel.h: add missing ams/byteorder.h include
Date: Sun, 21 Mar 2010 21:19:33 -0700 (PDT)
Message-ID: <20100321.211933.35812457.davem@davemloft.net>
References: <20100319150926.11037.39136.stgit@pauliusz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: contact@saschahlusiak.de, eric.dumazet@gmail.com,
	Fred.L.Templin@boeing.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulius.zaleckas@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100319150926.11037.39136.stgit@pauliusz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Fri, 19 Mar 2010 17:09:26 +0200

> When compiling userspace application which includes
> if_tunnel.h and uses GRE_* defines you will get undefined
> reference to __cpu_to_be16.
> 
> Fix this by adding missing #include <asm/byteorder.h>
> 
> Cc: stable@kernel.org
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>

This slipped through the cracks, someone else submitted something
similar back in August 2009 it seems.

Thanks for sending this, applied.

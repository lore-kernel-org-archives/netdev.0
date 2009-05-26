From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: fix regression caused during net_device_ops
 conversion
Date: Mon, 25 May 2009 22:44:01 -0700 (PDT)
Message-ID: <20090525.224401.11926225.davem@davemloft.net>
References: <Pine.LNX.4.64.0905260116120.18180@loopy.telegraphics.com.au>
	<Pine.LNX.4.64.0905261243230.22373@loopy.telegraphics.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, linux-m68k@vger.kernel.org,
	netdev@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0905261243230.22373@loopy.telegraphics.com.au>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Tue, 26 May 2009 12:50:12 +1000 (EST)

> 
> Changeset ca17584bf2ad1b1e37a5c0e4386728cc5fc9dabc broke mac8390 by adding 
> 8390.o to the link. That meant that lib8390.c was included twice, once in 
> mac8390.c and once in 8390.c, subject to different macros. This patch 
> reverts that by avoiding the wrappers in 8390.c. They seem to be of no 
> value since COMPAT_NET_DEV_OPS is going away soon.
> 
> Tested with a Kinetics EtherPort card.
> 
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Patch applied, thanks.

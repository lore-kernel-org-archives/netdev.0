From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] cxgb3: FIx VLAN over Jumbo frames
Date: Mon, 15 Feb 2010 21:53:07 -0800 (PST)
Message-ID: <20100215.215307.118784851.davem@davemloft.net>
References: <20100213194429.27297.99280.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100213194429.27297.99280.stgit@speedy5.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Sat, 13 Feb 2010 11:44:30 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> The mac is expected to auto-inflate the Maximum Frame size for VLAN
> tagged frames. It however does not work with jumbo frames.
> Work around the bug adding 4 to the Maximum Frame for MTUs
> greater than 1536.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.

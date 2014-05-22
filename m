From: David Miller <davem@davemloft.net>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 16:58:33 -0400 (EDT)
Message-ID: <20140522.165833.414855217799383878.davem@davemloft.net>
References: <537E4AFD.20304@mentor.com>
	<20140522.152146.2116142050088142989.davem@davemloft.net>
	<537E5C63.7080607@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kamal@canonical.com,
	bhutchings@solarflare.com, edumazet@google.com, mszeredi@suse.cz,
	fw@strlen.de
To: jim_baxter@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537E5C63.7080607@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Baxter <jim_baxter@mentor.com>
Date: Thu, 22 May 2014 21:21:55 +0100

> If there are multiple clones for an skb all pointing at the same data,
> will that distort the memory used when they all have the same truesize?

What is distorted about it?

Each clone references exactly that much backing memory.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] etherdevice: Add ether_addr_copy_unaligned
Date: Mon, 20 Apr 2015 14:19:14 -0400 (EDT)
Message-ID: <20150420.141914.1605864056122893264.davem@davemloft.net>
References: <1429479577-3977-1-git-send-email-mateusz.kulikowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, dan.carpenter@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mateusz.kulikowski@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429479577-3977-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Date: Sun, 19 Apr 2015 23:39:37 +0200

> Some drivers require copying unaligned ethernet addresses.
> Using memcpy() causes checkpatch warnings and may cause
> regressions (someone will "fix" alignment of packed structure)
> 
> Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>

I'd rather see something like this submitted in a patch series alongside
some actual uses.

So I'm tossing this for now.

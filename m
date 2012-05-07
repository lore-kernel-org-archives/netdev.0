From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Adding read memory barriers
Date: Mon, 07 May 2012 13:57:56 -0400 (EDT)
Message-ID: <20120507.135756.771396536686434223.davem@davemloft.net>
References: <4FA80B46.5070405@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tshimizu818@gmail.com
To: erwanaliasr1@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FA80B46.5070405@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Your patch doesn't apply to the net-next tree which is what you should
be basing all of your networking patches on:

[davem@bql net-next]$ git am --signoff pch_gbe-Adding-read-memory-barriers.patch 
Applying: pch_gbe: Adding read memory barriers
error: patch failed: drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c:1222
error: drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c: patch does not apply
Patch failed at 0001 pch_gbe: Adding read memory barriers
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

Stop rushing things and take your time learning the process.

Otherwise you're going to make more work for maintainers and they
end up grumpy as a result, which you don't want.

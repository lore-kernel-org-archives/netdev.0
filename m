From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] smsc: Enabling SMSC LAN911 driver for ARM64 as
 well.
Date: Mon, 11 Jan 2016 17:45:47 -0500 (EST)
Message-ID: <20160111.174547.403936696977744988.davem@davemloft.net>
References: <1452502945-27765-1-git-send-email-manjeet.p@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, schmitzmic@gmail.com,
	geert@linux-m68k.org, nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akhilesh.k@samsung.com,
	pankaj.m@samsung.com
To: manjeet.p@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452502945-27765-1-git-send-email-manjeet.p@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Manjeet Pawar <manjeet.p@samsung.com>
Date: Mon, 11 Jan 2016 14:32:25 +0530

> This patch enable network driver support for ARM64
> 
> Signed-off-by: Akhilesh Kumar <akhilesh.k@samsung.com>
> Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>

There is no _WAY_ this is valid.

This driver casts skb->data pointers to "u32" integers
and then casts it back to a pointer and proceeds to
dereference that pointer.

I don't think you even looked at the build when trying to
compile this on a 64-bit machine.

That makes me have absolutely no confidence in the changes
you submit to me.

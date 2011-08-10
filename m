From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Tue, 09 Aug 2011 21:11:37 -0700 (PDT)
Message-ID: <20110809.211137.1412336654766141870.davem@davemloft.net>
References: <1312943316.11924.54.camel@Joe-Laptop>
	<CANxBZFpm-at-FgNdP9nefwFfpzHmTMMsPSNWKJuT2R6TazhsYQ@mail.gmail.com>
	<1312949237.11924.58.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stufever@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, wangshaoyan.pt@taobao.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312949237.11924.58.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 09 Aug 2011 21:07:17 -0700

> On Wed, 2011-08-10 at 11:50 +0800, Wang Shaoyan wrote:
>> Yes, I want to test, but I can't open CONFIG_GIANFAR, because I can't
>> find FSL_SOC, am i miss something?
> 
> A cross compiler for powerpc?

This is really misleading, because in the commit message the stack
usage message is reported but the patch submitted obviously didn't
generate that message since they can't even build test this change.

I'm not going to apply this until someone both build and functionally
tests this patch.

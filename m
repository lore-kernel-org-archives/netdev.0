From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: dst_entries_init() per-net dst_ops
Date: Wed, 28 Oct 2015 07:07:42 -0700 (PDT)
Message-ID: <20151028.070742.403991225070921299.davem@davemloft.net>
References: <1445962519-16133-1-git-send-email-dan.streetman@canonical.com>
	<CAOZ2QJMuPoSrrFdudiGYQ4PjvELbonqg94X2mQaUhZ-R5yS0hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ddstreet@ieee.org
To: dan.streetman@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOZ2QJMuPoSrrFdudiGYQ4PjvELbonqg94X2mQaUhZ-R5yS0hw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Streetman <dan.streetman@canonical.com>
Date: Wed, 28 Oct 2015 09:32:47 -0400

> Well I'm not sure why my test kernel booted, while the test robot
> found the bug of GFP_KERNEL percpu counter alloc during atomic
> context.  Thanks test robot!

It's because of the kernel config options you (don't) have
enabled.

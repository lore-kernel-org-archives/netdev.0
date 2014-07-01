From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Mon, 30 Jun 2014 23:48:43 -0700 (PDT)
Message-ID: <20140630.234843.985671994258957329.davem@davemloft.net>
References: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: edward.allcutt@openmarket.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Edward Allcutt <edward.allcutt@openmarket.com>
Date: Mon, 30 Jun 2014 16:16:02 +0100

> This is explicitly described as an eventuality that hosts must deal
> with by the standard (RFC 1191) since older standards specified that
> those bits must be zero.
 ...
> One example I have seen is an OpenBSD router terminating IPSec
> tunnels.

Why doesn't OpenBSD implement RFC 1191?

That's a nearly 24 year old standard.

I really don't want to allow for zero values.

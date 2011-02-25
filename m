From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Fri, 25 Feb 2011 11:16:06 -0800 (PST)
Message-ID: <20110225.111606.115927805.davem@davemloft.net>
References: <20110225190205.GA4541@albatros>
	<20110225.110529.39178636.davem@davemloft.net>
	<1298660879.2554.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298660879.2554.23.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 25 Feb 2011 19:07:59 +0000

> You realise that module loading doesn't actually run in the context of
> request_module(), right?

Why is that a barrier?  We could simply pass a capability mask into
request_module if necessary.

It's an implementation detail, and not a deterrant to my suggested
scheme.

From: Andi Kleen <ak@suse.de>
Subject: Re: FreeSWAN's pfkey_v2.c
Date: Thu, 17 Oct 2002 04:50:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017045054.A405@wotan.suse.de>
References: <200210170248.g9H2m6bf011892@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: design@lists.freeswan.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <200210170248.g9H2m6bf011892@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I am looking for confirmation from network stack people that my conclusions
> from reading of the macros in linux/net.h is correct.

What you should actually do is to add explicit proper SMP locking.
Then you don't need any SOCKOPS_WRAP hacks.

-Andi

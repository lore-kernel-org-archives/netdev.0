From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Fix 64bit bugs in dscc4.c
Date: Tue, 7 Oct 2003 23:48:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007234842.A5234@electric-eye.fr.zoreil.com>
References: <20031007175953.GA1802@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ncorbic@sangoma.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20031007175953.GA1802@averell>; from ak@muc.de on Tue, Oct 07, 2003 at 07:59:53PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@muc.de> :
[...]
> ioremap_nocache returns unsigned long, not u32. This makes a difference
> on 64bit hosts.

No 64 bit host to test the patch but it looks fine.

--
Ueimor - happily maintaining dscc4 driver since 2.4.3

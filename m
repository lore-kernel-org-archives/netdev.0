From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch-kj] net/ipv4/fib_hash.c: check kmem_cache_create()
Date: Tue, 22 Jun 2004 08:51:21 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622.085121.05747685.yoshfuji@linux-ipv6.org>
References: <20040621171832.GE1545@sputnik.stro.at>
	<20040622.032138.58652005.yoshfuji@linux-ipv6.org>
	<20040621200420.GI1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, janitor@sternwelten.at, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: max@stro.at
In-Reply-To: <20040621200420.GI1545@sputnik.stro.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040621200420.GI1545@sputnik.stro.at> (at Mon, 21 Jun 2004 22:04:20 +0200), maximilian attems <max@stro.at> says:

> doesn't seem to be enough,
> because if (tb == NULL) fn_hash_kmem won't be freed, 
> or am i overseeing something?

I believe fn_hash_kmem is not required to (and should not) be freed even 
if kmalloc() fails for the new table.
Users in existing table should be able to continue using fn_hash_kmem.

--yoshfuji

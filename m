From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC/PATCH 2/4] UDP memory usage accounting (take 4): accounting unit and variable
Date: Sun, 7 Oct 2007 14:09:38 +0400
Message-ID: <20071007100938.GA24475@2ka.mipt.ru>
References: <47065139.5030402@hitachi.com> <470651B3.6060001@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, ?? ?? <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58653 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbXJGKLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 06:11:00 -0400
Content-Disposition: inline
In-Reply-To: <470651B3.6060001@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Sat, Oct 06, 2007 at 12:01:07AM +0900, Satoshi OSHIMA (satoshi.oshima.fk@hitachi.com) wrote:
> --- 2.6.23-rc3-udp_limit.orig/net/ipv4/udp.c
> +++ 2.6.23-rc3-udp_limit/net/ipv4/udp.c
> @@ -113,6 +113,10 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
>  struct hlist_head udp_hash[UDP_HTABLE_SIZE];
>  DEFINE_RWLOCK(udp_hash_lock);
>  
> +atomic_t udp_memory_allocated;
> +
> +EXPORT_SYMBOL(udp_memory_allocated);
> +

Why do you export this variable?
It is not accessed from modules in your patchset.

-- 
	Evgeniy Polyakov

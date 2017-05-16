From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for May 16 (net/core)
Date: Tue, 16 May 2017 09:28:30 -0700
Message-ID: <f63533e7-edd3-4c0d-ddff-e3409d15abc6@infradead.org>
References: <20170516112125.517607f8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:54707 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753082AbdEPQ2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:28:32 -0400
In-Reply-To: <20170516112125.517607f8@canb.auug.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/17 18:21, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20170515:
> 

on i386 or x86_64:

when CONFIG_INET is not enabled:

../net/core/sock.c: In function 'skb_orphan_partial':
../net/core/sock.c:1810:2: error: implicit declaration of function 'skb_is_tcp_pure_ack' [-Werror=implicit-function-declaration]
  if (skb_is_tcp_pure_ack(skb))
  ^



-- 
~Randy

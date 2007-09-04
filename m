From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: 2.6.23-rc4-mm1 net bitops compile error
Date: Tue, 04 Sep 2007 19:53:16 +0200
Message-ID: <46DD9B8C.2060400@gmail.com>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070902091416.GJ16016@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:47868 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079AbXIDRwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 13:52:08 -0400
Received: by nf-out-0910.google.com with SMTP id f5so1502272nfh
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2007 10:52:07 -0700 (PDT)
In-Reply-To: <20070902091416.GJ16016@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk napsal(a):
> defconfig fails with the following error on parisc:
> 
> <--  snip  -->
> 
> ...
>   CC      net/core/gen_estimator.o
> In file included from include2/asm/bitops.h:111,
>                  from /home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/net/core/gen_estimator.c:18:
> /home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/include/asm-generic/bitops/non-atomic.h: 
> In function '__set_bit':
> /home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/include/asm-generic/bitops/non-atomic.h:17: 
> error: implicit declaration of function 'BIT_MASK'
> /home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/include/asm-generic/bitops/non-atomic.h:18: 
> error: implicit declaration of function 'BIT_WORD'
> make[3]: *** [net/core/gen_estimator.o] Error 1
> 
> <--  snip  -->
> 
> Either #include <asm/bitops.h> must become forbidden and #error or the 
> move of the #define's to include/linux/bitops.h reverted.

Just to let you know, that I'm working on the former.

thanks,
-- 
http://www.fi.muni.cz/~xslaby/            Jiri Slaby
faculty of informatics, masaryk university, brno, cz

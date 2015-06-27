From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Sat, 27 Jun 2015 16:09:02 +0900
Message-ID: <20150627070902.GB29671@gondor.apana.org.au>
References: <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514033448.GA5080@gondor.apana.org.au>
 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514041628.GA5428@gondor.apana.org.au>
 <20150514042151.GA5482@gondor.apana.org.au>
 <558D2CF4.5070503@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40174 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbbF0HJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 03:09:08 -0400
Content-Disposition: inline
In-Reply-To: <558D2CF4.5070503@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2015 at 01:44:04PM +0300, Konstantin Khlebnikov wrote:
>
> I've found race in v3.18 in __netlink_lookup: rhashtable_hashfn
> computes hash using one table and following rhashtable_lookup_compare
> dereferences ht->tbl once again and could see different table.
> 
> patch follows...

Sounds like this is it.  Thanks for digging into this!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

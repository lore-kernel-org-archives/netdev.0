From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Thu, 14 May 2015 12:16:28 +0800
Message-ID: <20150514041628.GA5428@gondor.apana.org.au>
References: <20150513054037.GA26595@gondor.apana.org.au>
 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150513062038.GA26944@gondor.apana.org.au>
 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514033448.GA5080@gondor.apana.org.au>
 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54455 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbbENEQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:16:36 -0400
Content-Disposition: inline
In-Reply-To: <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 09:13:38PM -0700, Eric Dumazet wrote:
>
> So it looks like we lost an skb or something....

OK that sounds reasonable.  So my plan is to disable dynamic
rehashing and then hunt down this lookup bug.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

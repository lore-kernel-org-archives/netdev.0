From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] ipv[46]: Fix MD5 signatures for non-linear skbs
Date: Mon, 7 Jul 2008 10:21:31 -0700
Message-ID: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe069000@europa>
	 <20080704082402.GA16259@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:17734 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523AbYGGRVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 13:21:32 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2779971rvb.1
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 10:21:31 -0700 (PDT)
In-Reply-To: <20080704082402.GA16259@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 4, 2008 at 1:24 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> A trivial nit: you can use sg_init_one() to initialize single
> scatterlist and set data pointer instead of sg_init_table()/sg_set_buf()
> in all places where you use single sg.

Thanks both. Respun patch in a second...
Changes: Use sg_init_one where possible and take a couple of ifs out
of tcp_md5_hash_skb_data

AGL


-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org

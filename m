From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/10] [SKBUFF]: Merge common code between
	copy_skb_header and skb_clone
Date: Sun, 14 Oct 2007 06:36:59 -0400
Message-ID: <1192358219.4892.17.camel@localhost>
References: <20071014042604.GA11431@gondor.apana.org.au>
	 <E1Igv4l-000306-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:11344 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282AbXJNKhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 06:37:04 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1406596wxd
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 03:37:03 -0700 (PDT)
In-Reply-To: <E1Igv4l-000306-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sun, 2007-14-10 at 12:27 +0800, Herbert Xu wrote:

> In fact the tc_verd stuff is almost certainly a bug since it's treated
> differently in skb_clone compared to the callers of copy_skb_header
> (skb_copy/pskb_copy/skb_copy_expand).
> 
> I've kept that difference in tact with a comment added asking for
> clarification. 

attempted clarification here:
http://marc.info/?l=linux-netdev&m=119226270510948&w=2


cheers,
jamal


From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [bisected] no traffic on ssl vpn with 3.19rc1 - 3.19rc3
Date: Fri, 9 Jan 2015 07:57:45 +1100
Message-ID: <20150108205745.GA13460@gondor.apana.org.au>
References: <CAHQNsofShzPsOgtEZw1HHpOvJW5fo+MQtO8Ys6Uqsc+SN_LaLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Billy Shuman <wshuman3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37109 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbbAHU5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 15:57:49 -0500
Content-Disposition: inline
In-Reply-To: <CAHQNsofShzPsOgtEZw1HHpOvJW5fo+MQtO8Ys6Uqsc+SN_LaLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Billy Shuman <wshuman3@gmail.com> wrote:
> 
> Since 3.19rc1 I get 100% packet loss through SSL vpn.  I bisected with
> the following result:
> 
> 0b46d0ee9c240c7430a47e9b0365674d4a04522 is the first bad commit
> commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Nov 7 21:22:23 2014 +0800
> 
>    tun: Use iovec iterators
> 
>    This patch removes the use of skb_copy_datagram_const_iovec in
>    favour of the iovec iterator-based skb_copy_datagram_iter.
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=90901

This changeset is known to be buggy.  However it was fixed ages
ago by changeset 8c847d254146d32c86574a1b16923ff91bb784dd.

So please test that changeset to see if it works for you.  If it
does, then please do your bisection between that and the current
top of tree.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

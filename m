From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [bisected] no traffic on ssl vpn with 3.19rc1 - 3.19rc3
Date: Thu, 08 Jan 2015 11:22:19 -0200
Message-ID: <54AE848B.5070407@redhat.com>
References: <CAHQNsofShzPsOgtEZw1HHpOvJW5fo+MQtO8Ys6Uqsc+SN_LaLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
To: Billy Shuman <wshuman3@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074AbbAHNW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 08:22:27 -0500
In-Reply-To: <CAHQNsofShzPsOgtEZw1HHpOvJW5fo+MQtO8Ys6Uqsc+SN_LaLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-01-2015 17:10, Billy Shuman wrote:
> Hi,
>
> Since 3.19rc1 I get 100% packet loss through SSL vpn.  I bisected with
> the following result:
>
> 0b46d0ee9c240c7430a47e9b0365674d4a04522 is the first bad commit
> commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Nov 7 21:22:23 2014 +0800
>
>      tun: Use iovec iterators
>
>      This patch removes the use of skb_copy_datagram_const_iovec in
>      favour of the iovec iterator-based skb_copy_datagram_iter.
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=90901

Interesting. Similar effect that I had but your version has the fix already.
http://article.gmane.org/gmane.linux.network/340700

   Marcelo

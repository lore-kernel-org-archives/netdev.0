From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: is each frag of a skb always less than 1 page?
Date: Wed, 11 Oct 2006 09:30:04 +0200
Message-ID: <20061011073004.GA1671@ff.dom.local>
References: <ba020e9f0610101626rf20ce7bg1c214f91f05fb975@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:36740 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932462AbWJKHZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 03:25:18 -0400
To: Ronghua Zhang <ronghuazhang@gmail.com>
Content-Disposition: inline
In-Reply-To: <ba020e9f0610101626rf20ce7bg1c214f91f05fb975@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-10-2006 01:26, Ronghua Zhang wrote:
...
> The reason I asked this is that I saw the following code in forthdeth 
> drvier:
> 
> #define NV_TX2_TSO_MAX_SHIFT) 14
> /* add fragments to entries count */
> for (i = 0; i < fragments; i++) {
>    entries += (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT) +
>                    ((skb_shinfo(skb)->frags[i].size &
> (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
> }
> 
> This looks unnecessary if each frag is guaranteed not to span pages.

Even if PAGE_SIZE > NV_TX2_TSO_MAX_SIZE?

Jarek P.

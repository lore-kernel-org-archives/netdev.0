From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH stable <= 3.18] net: add length argument to
 skb_copy_and_csum_datagram_iovec
Date: Mon, 16 Nov 2015 19:06:46 +0100
Message-ID: <20151116180646.GA21594@bistromath.redhat.com>
References: <c1b23313f94ba3fd9977c6fba61483edf6489b5f.1444910940.git.sd@queasysnail.net>
 <20151029100021.GA17588@bistromath.redhat.com>
 <CAKA=qzZCi_OEDJKgy1WQ1QdMBpHBure1tY7NYtsgSr0fMva5jQ@mail.gmail.com>
 <20151111000352.GA5134@kroah.com>
 <20151112094822.GA21732@bistromath.redhat.com>
 <1447349202.22599.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Josh Hunt <joshhunt00@gmail.com>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, stable <stable@vger.kernel.org>,
	hannes@stressinduktion.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447349202.22599.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric

2015-11-12, 09:26:42 -0800, Eric Dumazet wrote:
> Note that the following patch (and corresponding part for ipv6) might
> also have solve the issue ?
> 
> This would supposedly save some cycles when MSG_PEEK is used and user
> provides short buffers.

Your patch looks correct to me, feel free to submit it.

Since some stable trees already include my patch, maybe it should be
reverted there to keep all trees in sync and ease future backports?


Thanks,

-- 
Sabrina

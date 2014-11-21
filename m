From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH v2 net] net: Revert "net: avoid one atomic operation in
 skb_clone()"
Date: Fri, 21 Nov 2014 16:15:56 -0500
Message-ID: <1416604556.24312.11@mail.thefacebook.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	<1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416589451.8629.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141121180510.GA22112@kria>
	<1416598161.8629.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416599236.8629.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41318 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750802AbaKUVQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 16:16:06 -0500
In-Reply-To: <1416599236.8629.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2014 at 2:47 PM, Eric Dumazet <eric.dumazet@gmail.com> 
wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> v2: the revert went wrong, as SKB_FCLONE_UNAVAILABLE
>     was later replaced by SKB_FCLONE_FREE, spotted by Sabrina Dubroca
> 

v2 is happy here too.  I'll let it keep going over the weekend and add 
more memory pressure, but my crashes seem to be gone.

-chris

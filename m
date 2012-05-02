From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 10:24:44 +0200
Message-ID: <1335947084.22133.134.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop>  <4FA03D69.6060907@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48413 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab2EBIYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 04:24:51 -0400
Received: by eaaq12 with SMTP id q12so80632eaa.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 01:24:50 -0700 (PDT)
In-Reply-To: <4FA03D69.6060907@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 12:45 -0700, Alexander Duyck wrote:

> I have a hacked together ixgbe up and running now with the new build_skb
> logic and RSC/LRO disabled.  It looks like it is giving me a 5%
> performance boost for small packet routing, but I am using more CPU for
> netperf TCP receive tests and I was wondering if you had seen anything
> similar on the tg3 driver?

Really hard to say, numbers are so small on Gb link :

what do you use to make your numbers ?

netperf -H 172.30.42.23 -t OMNI -C -c 
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.23 (172.30.42.23) port 0 AF_INET
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1700840     1700840     16384  10.01   931.60     10^6bits/s  4.50  S      1.32   S      1.582   2.783   usec/KB  

About ixgbe, feel free to send your patch ;)

Thanks !

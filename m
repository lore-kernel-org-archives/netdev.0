From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 15 Apr 2009 16:42:48 -0700 (PDT)
Message-ID: <20090415.164248.188350673.davem@davemloft.net>
References: <20090415.030213.249634462.davem@davemloft.net>
	<49E5DABB.9070806@myri.com>
	<49E64BE4.1050908@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com, sgruszka@redhat.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32879
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752460AbZDOXm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 19:42:57 -0400
In-Reply-To: <49E64BE4.1050908@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 15 Apr 2009 17:04:36 -0400

> Andrew Gallatin wrote:
>> Unfortunately, it doesn't appear that GRO is able to handle frags
>> (like lro_receive_frags()), so I anticipate its overhead would
> 
> Ah, I missed napi_gro_frags()!   I've got quick and dirty test
> patch which uses that, but I need to fix a few things. I also need
> to figure out why it seems to be a bit slower than LRO
> (varies from 8.5 to 9.2 Gb/s, rather than always 9.4Gb/s)
> on my old, weak 2.0GHz athlon64.

Herbert has been working on various optimizations to get
cxgb3 GRO performance on par with LRO.  Perhaps he has
some things for you to try :-)

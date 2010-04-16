From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next-2.6 PATCH 2/2] net: replace ipfragok with
	skb->local_df
Date: Fri, 16 Apr 2010 14:43:44 +0800
Message-ID: <20100416064344.GA12412@gondor.apana.org.au>
References: <4BC70EF1.6080400@cn.fujitsu.com> <20100415151926.GA4813@gondor.apana.org.au> <4BC7CAC1.4000803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, yinghai.lu@oracle.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	dccp@vger.kernel.org, linux-sctp@vger.kernel.org,
	kleptog@svana.org, jchapman@katalix.com, mostrows@speakeasy.net,
	acme@xconectiva.com.br
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38985 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755465Ab0DPGoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:44:25 -0400
Content-Disposition: inline
In-Reply-To: <4BC7CAC1.4000803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 10:26:09AM +0800, Shan Wei wrote:
> 
> Now, PPPoX/PPPoL2TP driver still use ip_queue_xmit to send packets with ipfragok == 1.
> So, now we can't remove the && ... bit. 

Huh? If they still call ip_queue_xmit with ipfragok then surely
the build will fail after your patch as it removes the ipfragok
argument?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

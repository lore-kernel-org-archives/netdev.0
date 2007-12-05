From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 05 Dec 2007 17:20:25 +0800
Message-ID: <47566D59.1080905@cn.fujitsu.com>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au> <47560215.6050104@cn.fujitsu.com> <20071205021559.GA27707@gondor.apana.org.au> <475663D4.9040806@cn.fujitsu.com> <20071205090228.GA14659@gondor.apana.org.au> <475669B0.4030501@cn.fujitsu.com> <20071205091028.GA15006@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:53738 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbXLEJXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 04:23:13 -0500
In-Reply-To: <20071205091028.GA15006@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu said the following on 2007-12-5 17:10:
> On Wed, Dec 05, 2007 at 05:04:48PM +0800, Wang Chen wrote:
>> Yes, now, sunrpc only supports INET and INET6.
>> But UDPX_INC_STATS_BH is defined in udp.h, in case others use it :)
> 
> Which other family would that be :)
> 

Maybe AF_UNSPEC? It's joke:)
I just more like switch to avoid false positive problem.


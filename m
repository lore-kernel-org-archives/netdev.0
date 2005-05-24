From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Super TSO v3
Date: Tue, 24 May 2005 09:12:21 -0700
Message-ID: <42935265.3040103@hp.com>
References: <20050524003208.GA25778@gondor.apana.org.au>	<20050523.192917.48530622.davem@davemloft.net>	<20050524023256.GA29242@gondor.apana.org.au> <20050523.193817.112290763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050523.193817.112290763.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 24 May 2005 12:32:57 +1000
> 
> 
>>True, the Nagle algorithm itself aims to do something different
>>from this function.  However, the act of turning Nagle off is
>>an indication that the application wants to minimise the latency
>>by sending things out ASAP.  So we should either respect that
>>here by not delaying the packets to increase the TSO size, or
>>we'll need a new socket option to do that for TSO.
> 
> 
> Sure, we can check tp->nonagle to turn this deferring off.
> 
> But, I bet there are folks who want traditional Nagle turned
> off, yet TSO chunking enabled.

I'm not sure there will be very many of those.  I would have thought the folks 
who turn-off Nagle are  typically doing small sends.  If they were not wanting 
to wait to aggregate their small sends into MSS segments, or wait for the RTT, I 
doubt thet are looking to wait to aggregate to something larger than the MSS.

rick jones

From: Patrick McHardy <kaber@trash.net>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 02:47:28 +0100
Message-ID: <41917330.6090002@trash.net>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041110013941.GL31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>* Patrick McHardy <41916F0B.5010809@trash.net> 2004-11-10 02:29
>  
>
>>Assuming all error-paths do proper cleanup, returning -EAGAIN
>>should always result in the same configuration state as before.
>>    
>>
>
>I agree but this assumption is wrong, at least for u32.
>
It will be true soon :) Anything else is a bug, and a nice
side-effect of this change is that all those dusty error-paths
actually get used.

>I agree
>that once this is true it would work perfectly fine, however I 
>think it would be inefficient to parse the whole TLV tree multiple
>times.
>  
>
It will only happen once for every module, so I don't think
it's a big deal.

Regards
Patrick

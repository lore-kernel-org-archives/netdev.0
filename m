From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 02:13:35 +0200
Message-ID: <426841AF.2060404@trash.net>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de> <20050421214618.GA29991@gondor.apana.org.au> <1114127419.10572.4.camel@localhost.localdomain> <20050421235802.GB10451@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>,
        Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050421235802.GB10451@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Apr 21, 2005 at 07:50:19PM -0400, jamal wrote:
> 
>>What was the reason there exist a FWD direction in the policies?
> 
> You should really ask Alexey about that :) I myself had the same
> question when I first started in this area.  However, since it
> has been present since the very beginning and people are already
> relying on it, we will have to live with it.

I guess it was for performance reasons. A router that only needs
IPsec for management doesn't need to perform policy checks for
forwarded packets, which makes sense too me.

Regards
Patrick

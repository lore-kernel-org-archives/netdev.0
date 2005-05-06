From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: MultiPath Routing
Date: Fri, 06 May 2005 13:16:46 +0200
Message-ID: <427B521E.2040302@rapidforum.com>
References: <E1DU0XM-0001wJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DU0XM-0001wJ-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I tried disabling MULTIPATH_CACHED and now it completely works :) Thank you for your help. I thought 
your hint only is for NATed traffic but it seems its for all traffic.

Herbert Xu wrote:
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
>>Yes I enabled it. But it shouldnt do anything because its no forwarded traffic here. I just used 
>>example-IPs. Or does the bug also break non-forwarded traffic?
> 
> 
> Did you select one of the multipath algorithm options? If you selected
> them as modules did you load them? If no algorithms are available it
> will degenerate into deterministic routing.
> 
> It will also work properly if you disable IP_ROUTE_MULTIPATH_CACHED
> completely.
> 
> Cheers,

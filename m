From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: impressive throughput on 2.5.73
Date: Wed, 02 Jul 2003 19:58:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F039BE1.2080008@us.ibm.com>
References: <1057193766.31286.843.camel@nighthawk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Scott Feldman <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1057193766.31286.843.camel@nighthawk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave Hansen wrote:

> 176 requests/sec - 110.0 MB/second - 0.6 MB/request
> 
> Server CPU breakdown.
>  2% system
>  7% user
> 91% idle
> 

> client profile:
>  33363 total                                      0.0196
>   9575 poll_idle                                132.9861
>   5099 __copy_user_intel                         32.6859
>   3307 schedule                                   2.1418
>   1753 __wake_up                                 39.8409
>    667 tcp_v4_rcv                                 0.3382

Nice numbers :). In addition to NAPI, would be nice to
stick in more adapters. Any idea why __wake_up should be
so expensive on the client side?

thanks,
Nivedita

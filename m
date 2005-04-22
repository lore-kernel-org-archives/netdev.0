From: Chris Friesen <cfriesen@nortel.com>
Subject: Re: 2.6.9 BUG in tcp_transmit_skb at net/ipv4/tcp_output.c -- full
 output
Date: Fri, 22 Apr 2005 16:13:06 -0600
Message-ID: <426976F2.3000604@nortel.com>
References: <E1DP5xU-0000ZG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DP5xU-0000ZG-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> There's been lots of fixes to the TSO code since 2.6.9.  Please test
> 2.6.11.7 instead.

Unfortunately I can't move to the latest. We have a bunch ofkernel 
modules from various vendors, board support packages that aren't in 
mainline, etc.  We're in the process of moving to 2.6.10 and that 
requires support from six separate companies.  It's a mess.

If it matters, I'm on a G5 with the sungem driver (which I don't think 
supports TSO).  I've already applied the last -ac patch for 2.6.9 which 
has a number of fixes for 2.6.9 TCP issues, but apparently not all of 
them were caught.

Any pointers you can give me?

Chris

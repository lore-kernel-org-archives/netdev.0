From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: NAPI on 8139too
Date: Thu, 28 Aug 2003 17:01:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4E6D8F.6070003@pobox.com>
References: <1062094999.3149.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: smarchetto1@tin.it
In-Reply-To: <1062094999.3149.33.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michele 'mydecay' Marchetto wrote:
> I was wondering why NAPI hasn't been ported on 8139too yet..


I think it would be a good idea.  You can stuff a lot of 68-byte packets 
into a 32K or 64K contiguous buffer.  Jes Sorensen wrote a patch a while 
ago that sampling the incoming rate, and backed off if the rate was too 
high -- basically a poor man's NAPI.

So, volunteers?  Just convert the RX path to NAPI, not all interrupt events.

	Jeff

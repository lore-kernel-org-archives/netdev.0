From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [TG3] Always load TSO firmware
Date: Thu, 20 Nov 2003 12:41:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBCFCBD.5060609@pobox.com>
References: <20031117093225.GA12420@gondor.apana.org.au>	<20031117123836.2f8e70af.davem@redhat.com>	<20031120095605.GA6572@gondor.apana.org.au> <20031120092530.4dfe9016.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031120092530.4dfe9016.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 20 Nov 2003 20:56:05 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> 
>>OK, I've cross-checked with the Broadcom drivers and the problem seems
>>to be specific to 5705 A1 which is the chipset in question.
>>
>>The Broadcom drivers limit the number of rx descriptors to 63 while
>>tg3.c only limits it to 64.  It has been confirmed that lowering
>>the limit makes the problem go away.
>>
>>Here is the patch.
> 
> 
> Great work.
> 
> Jeff, please push this around.  I think it's serious enough for
> 2.4.23-rcX personally.


Will do, though I first need to check and see if non-power-of-two has 
any implications in the implementation...

	Jeff

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]: r8169: Message level support
Date: Sat, 26 Feb 2005 16:20:43 -0500
Message-ID: <4220E82B.6080309@pobox.com>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk> <20050226203518.GA14688@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050226203518.GA14688@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff, can you send a ack/nack if you disagree with the remarks below ?
> 
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
> 
>>There seems to be a mixture of drivers using a bitfield and a level. 
>>Which is the currently preferred mechanism?
> 
> 
> They do not offer exactly the same range. I prefer to keep both as the
> module option is not that expensive.

* The preferred mechanism is to have an integer verbosity level 'debug', 
which is converted using netif_msg_init() into a bitmap.

* PFX should only be used in probe paths.  In all other cases, dev->name 
should be used.

* I strongly agree with the comment "Imho the driver should not poke its 
nose into the guts of netif_msg_xxx()"

	Jeff

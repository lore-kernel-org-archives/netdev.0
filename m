From: Sam Leffler <sam@errno.com>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 12:56:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182A05F.1080505@errno.com>
References: <1099030958.4944.148.camel@uganda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1099030958.4944.148.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> I'm pleased to announce asynchronous crypto layer for Linux kernel 2.6.
> It support following features:
> - multiple asynchronous crypto device queues
> - crypto session routing
> - crypto session binding
> - modular load balancing
> - crypto session batching genetically implemented by design
> - crypto session priority
> - different kinds of crypto operation(RNG, asymmetrical crypto, HMAC and
> any other)

It's really great to see this stuff come in to Linux.  Hopefully you're 
aware of existing functionality of this sort in each of the BSD systems? 
  It would be interesting to compare performance between systems.

I realize this suggestion will be met with the usual boo's and catcalls 
but it'd also be nice if all systems could share a common user-level api 
so, for example, you could just _use_ the support in openssl that's been 
around for several years.

	Sam

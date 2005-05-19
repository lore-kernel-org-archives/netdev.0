From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 00:08:09 -0700
Message-ID: <20050519000809.2fca25c5.akpm@osdl.org>
References: <20050518202458.55a63d37.akpm@osdl.org>
	<E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
	<20050518222729.007887b8.akpm@osdl.org>
	<1116484313.21310.78.camel@uganda>
	<20050518234552.4aef6d02.akpm@osdl.org>
	<1116486385.21310.82.camel@uganda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1116486385.21310.82.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>
>  > Is there any reason for being able to do that?
> 
>  It was created to be able to load several different connector devices 
>  from different modules [basically it was module1.ko unit=10, module2.ko
>  unit=11 and so on].

Loading multiple instances of the same module so that we get multiple
instances of its data structures?   That's fairly ghastly.

We should remove the feature.  If there is demonstrated need for multiple
instances then it should be done by more conventional means - syscall,
allocation of a device major then use the minor as a selector or whatever.

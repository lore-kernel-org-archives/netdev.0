From: Michal Ludvig <michal@logix.cz>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 16:53:30 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410291636020.25667@maxipes.logix.cz>
References: <1099030958.4944.148.camel@uganda> <1099053738.1024.104.camel@jzny.localdomain>
 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru> <41824D9A.3070407@logix.cz>
 <20041029183606.0b1a0538@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20041029183606.0b1a0538@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004, Evgeniy Polyakov wrote:

> > I have a very preliminary driver for FastCrypt PCI board for 3DES at
> > http://www.logix.cz/michal/devel/fcrypt/
> > For now it works with some very ugly hacks in the current cryptoapi, but
> > I can give it a try with your acrypto and report the results.
> 
> It would be very appreciated>

Re Hifn - you may be interested in this Linux driver:
http://kernel.ebshome.net/hifn7955-2.6-4.diff

> > I admit I haven't read your sources too deeply yet so excuse me a dumb
> > question - does acrypto replace or extend cryptoapi? Once I get it
> > running will it take over e.g. encryption for IPsec?
> 
> They are both an addendum to each other, 
> any crypto layer can be "tunrned into compatibility mode" - 
> i.e. anyone can write bridges like attached sha1_provider.c (it is bridge
> from async into sync mode). So I can not answer - but in _current_ 
> implementation without any kind of bridges it is an extension.
> 
> If you compile this sources then you will still have old sync behaviour, 
> IPsec and any other old-style application should be rewritten(like 
> attached consumer.c) to use new asynchronous crypto layer features.

This could be a bit of problem, because AFAIK the IPsec code doesn't allow 
sleeping while processing the packet. It will likely need a bigger 
rewrite.

Anyway, have you got any tool to measure the cipher throughput without 
IPsec/dm-crypt being updated for acrypto?

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/michal

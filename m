From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 13:56:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030205630.GD6256@gate.ebshome.net>
References: <1099030958.4944.148.camel@uganda> <1099053738.1024.104.camel@jzny.localdomain> <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru> <20041030203550.GB6256@gate.ebshome.net> <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 01:04:15AM +0400, Evgeniy Polyakov wrote:
> On Sat, 30 Oct 2004 13:35:50 -0700
> Eugene Surovegin <ebs@ebshome.net> wrote:
> 
> > On Fri, Oct 29, 2004 at 06:06:52PM +0400, Evgeniy Polyakov wrote:
> > > If we have a hardware accelerator chip, than we _already_ have improvements 
> > > with even the worst async crypto layer, since software and hardware 
> > > will work in parrallel.
> > 
> > This is not true. 
> > 
> > For example, if chip request setup and PCI transfer takes more than 
> > just using sw implementation. This is reality for AES and short 
> > packets.
> 
> You have dataflow of packets, if invoce expenses take less time
> then you will win.

Yes, but as I said for short packets, AES and fast box for example 
this might not be true.

> More than 1kbyte of data to be encrypted already beats time
> need for software encryption on 266 mhz.

OK, what about 64 byte packets? I'm not saying hw crypto is useless, 
what I'm saying is it's not that obvious that having hw crypto will 
help in _all_ situations.

> And what about asynchronous crypto? 

Asynchronous? Never heard of it. Did you mean asymmetric?

If yes, ok, I _think_ hw crypto will help, provided we have kernel API 
for such stuff.

--
Eugene

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 01:04:15 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<1099053738.1024.104.camel@jzny.localdomain>
	<20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	<20041030203550.GB6256@gate.ebshome.net>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Eugene Surovegin <ebs@ebshome.net>
In-Reply-To: <20041030203550.GB6256@gate.ebshome.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004 13:35:50 -0700
Eugene Surovegin <ebs@ebshome.net> wrote:

> On Fri, Oct 29, 2004 at 06:06:52PM +0400, Evgeniy Polyakov wrote:
> > If we have a hardware accelerator chip, than we _already_ have improvements 
> > with even the worst async crypto layer, since software and hardware 
> > will work in parrallel.
> 
> This is not true. 
> 
> For example, if chip request setup and PCI transfer takes more than 
> just using sw implementation. This is reality for AES and short 
> packets.

You have dataflow of packets, if invoce expenses take less time
then you will win.
More than 1kbyte of data to be encrypted already beats time
need for software encryption on 266 mhz.
What hardware requires PCI transfer that will take more time
than it's encryption?
And what about asynchronous crypto? 
Kernel currently even can not generate RSA keys, although
necessity of such feature is under the question.

> 
> --
> Eugene


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt

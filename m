From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 18:06:52 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<1099053738.1024.104.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099053738.1024.104.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Oct 2004 08:42:18 -0400
jamal <hadi@cyberus.ca> wrote:

> On Fri, 2004-10-29 at 02:22, Evgeniy Polyakov wrote:
> > I'm pleased to announce asynchronous crypto layer for Linux kernel 2.6.
> > It support following features:
> > - multiple asynchronous crypto device queues
> > - crypto session routing
> > - crypto session binding
> > - modular load balancing
> > - crypto session batching genetically implemented by design
> > - crypto session priority
> > - different kinds of crypto operation(RNG, asymmetrical crypto, HMAC and
> > any other)
> > 
> 
> Very nice.
> I am very curious if you see perfomance improvements over old scheme
> in the case of a single crypto chip in a fast CPU.
> It has been shown in the past that with a xeon in the range of 2Ghz the
> context setup and the big lock (and lack of async) implied that
> performance enhancement using a crypto chip was negligible.
> IIRC, the only time it started showing anything useful was when a
> compute intensive alg like 3DES was chewing packets >= 1000 bytes.
> 
> My suspicion is you will show it is better to use a crypto chip with
> async;-> In the minimal you should show some improvement.

If we have a hardware accelerator chip, than we _already_ have improvements 
with even the worst async crypto layer, since software and hardware 
will work in parrallel.
I agree that multigigahertz box will beat my HIFN card, 
but I doubt it can beat 1gghz VIA.
And what about random numbers, async crypto, TPM?
They all requires some kind of generalization.

> 
> cheers,
> jamal


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt

From: jamal <hadi@cyberus.ca>
Subject: Re: Asynchronous crypto layer.
Date: 29 Oct 2004 08:42:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099053738.1024.104.camel@jzny.localdomain>
References: <1099030958.4944.148.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1099030958.4944.148.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-29 at 02:22, Evgeniy Polyakov wrote:
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
> 

Very nice.
I am very curious if you see perfomance improvements over old scheme
in the case of a single crypto chip in a fast CPU.
It has been shown in the past that with a xeon in the range of 2Ghz the
context setup and the big lock (and lack of async) implied that
performance enhancement using a crypto chip was negligible.
IIRC, the only time it started showing anything useful was when a
compute intensive alg like 3DES was chewing packets >= 1000 bytes.

My suspicion is you will show it is better to use a crypto chip with
async;-> In the minimal you should show some improvement.


cheers,
jamal

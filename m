From: jamal <hadi@cyberus.ca>
Subject: Re: Asynchronous crypto layer.
Date: 29 Oct 2004 11:08:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099062483.1023.21.camel@jzny.localdomain>
References: <1099030958.4944.148.camel@uganda>
	 <1099053738.1024.104.camel@jzny.localdomain>
	 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-29 at 10:06, Evgeniy Polyakov wrote:


> If we have a hardware accelerator chip, than we _already_ have improvements 
> with even the worst async crypto layer, since software and hardware 
> will work in parrallel.

Thats what i am hoping - and theory points to it. Numbers, numbers
please ;->

> I agree that multigigahertz box will beat my HIFN card, 
> but I doubt it can beat 1gghz VIA.

The VIA is an interesting one; but it would still be interesting to see 
comparisons.
Actually I should say a good comparison will be with a dual opteron
>= 2Ghz which i have no doubt will smoke a xeon - all in s/ware.

> And what about random numbers, async crypto, TPM?
> They all requires some kind of generalization.
> 

Similar deferal approach should do it.
If you are brave, you should probably experiment as well with
non-crypto stuff to defer things like gettimeofday computes.
(i.e ask the hardware for time, defer response and then call netif_rx
with a tag saying time has been computed).

cheers,
jamal

From: Michal Ludvig <michal@logix.cz>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 16:03:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41824D9A.3070407@logix.cz>
References: <1099030958.4944.148.camel@uganda>	<1099053738.1024.104.camel@jzny.localdomain> <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov told me that:
> On 29 Oct 2004 08:42:18 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
>>>I am very curious if you see perfomance improvements over old scheme
>>in the case of a single crypto chip in a fast CPU.
>>It has been shown in the past that with a xeon in the range of 2Ghz the
>>context setup and the big lock (and lack of async) implied that
>>performance enhancement using a crypto chip was negligible.
>>IIRC, the only time it started showing anything useful was when a
>>compute intensive alg like 3DES was chewing packets >= 1000 bytes.
>>
>>My suspicion is you will show it is better to use a crypto chip with
>>async;-> In the minimal you should show some improvement.
> 
> 
> If we have a hardware accelerator chip, than we _already_ have improvements 
> with even the worst async crypto layer, since software and hardware 
> will work in parrallel.
> I agree that multigigahertz box will beat my HIFN card, 
> but I doubt it can beat 1gghz VIA.

I have a very preliminary driver for FastCrypt PCI board for 3DES at
http://www.logix.cz/michal/devel/fcrypt/
For now it works with some very ugly hacks in the current cryptoapi, but
I can give it a try with your acrypto and report the results.

I admit I haven't read your sources too deeply yet so excuse me a dumb
question - does acrypto replace or extend cryptoapi? Once I get it
running will it take over e.g. encryption for IPsec?

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/michal

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Kernel connector - userspace <-> kernelspace "linker".
Date: Thu, 16 Sep 2004 20:03:04 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916200304.4fad9b6d@zanzibar.2ka.mipt.ru>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Evgeniy Polyakov <s0mbre@tservice.net.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry for thread destruction, but I have not received you mail, 
but see it in archive. I do beleive it is due to permanent glitch of 
2ka.mipt.ru SMTP server.

> I dont have time to evaluate the code right now - but will at the end of
> day. Just trying to understand your concepts:
>
> Essentially you are building a unified messaging for
> userspace-userpace(i.e IPC), userspace-kernel, kernel-kernel with each
> component residing in whatever spot (kernel or userland)having a unique
> name and Id. Is this correct?

Actually name and ID should be transformed to ID0 and ID1(they are callled
idx and val and are u32 values, since I strongly object against any ASCII 
based identificators( sigh, I am cunning - superio has such ids)).
Since userspace can not register callback function, then it is not quite 
fair to call it generic, but the idea is right.

> Clearly there could be name/Id conflicts etc. Are you addressing those? 

Hmm, u32+u32 - I do not beleive that it can conflict, but if they do, then
first registered with given idx+val will pay the pipper and call the tune.
Second call with the same parameters for register_callback() fill fail.

> Any event and filtering capability already in or planned? Example event
> I want to be notified when module with name "sean paul" comes online and
> filter will be "it has to have ID in the range of 0x200-0x400".

Such information does exist in connector driver and it _can_ be easily 
obtained. I will call it feature request that fits the design 
and will implement this today/tomorrow. :)

> I am still trying to wakeup but it does sound like a good idea to have a
> generic messaging subsystem.

Good afternoon :).

cheers,
jamal 

	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt

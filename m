From: jamal <hadi@cyberus.ca>
Subject: Re: Kernel connector - userspace <-> kernelspace "linker".
Date: 16 Sep 2004 08:09:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095336548.1064.167.camel@jzny.localdomain>
References: <1095331899.18219.58.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1095331899.18219.58.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-16 at 06:51, Evgeniy Polyakov wrote:
> Hmm, do not know how to describe... 
> Kind of mega-picture can be found at 
> http://tservice.net.ru/~s0mbre/?section=gallery&item=connector_design
> 
> This driver adds possibility to connect anything with anything using
> netlink based network.
> One must register callback and identificator. When driver receives
> special netlink message with appropriate identificator, appropriate
> callback will be called.
> I think that the code better explains what I'm trying to say.

I dont have time to evaluate the code right now - but will at the end of
day. Just trying to understand your concepts:

Essentially you are building a unified messaging for
userspace-userpace(i.e IPC), userspace-kernel, kernel-kernel with each
component residing in whatever spot (kernel or userland)having a unique
name and Id. Is this correct?
Clearly there could be name/Id conflicts etc. Are you addressing those? 
Any event and filtering capability already in or planned? Example event
I want to be notified when module with name "sean paul" comes online and
filter will be "it has to have ID in the range of 0x200-0x400".

I am still trying to wakeup but it does sound like a good idea to have a
generic messaging subsystem.

cheers,
jamal 

From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 15:56:28 -0800
Message-ID: <424C8E2C.70302@candelatech.com>
References: <424C6089.1080507@candelatech.com>	 <1112303627.1073.71.camel@jzny.localdomain>	 <424C6B10.6030200@candelatech.com>	 <1112306031.1073.109.camel@jzny.localdomain>	 <424C7813.4000101@candelatech.com>	 <20050331143531.30f4eb8f.davem@davemloft.net>	 <424C7F96.4070002@candelatech.com> <1112311618.1090.20.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112311618.1090.20.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2005-03-31 at 17:54, Ben Greear wrote:
> 
> 
>>No.  I can't imagine a way to make it work with my application.
>>
> I think you are more comfortable with using netdevices and ioctls and
> /proc. 

Definately.  Ever tried to sniff a socket with ethereal? :)

> Why dont we try to help you so you migrate from the approach you are
> currently taking?

Our approaches to the problem are fundamentally different.  I choose
virtual net devices because all my user-space and GUI code that deals
with ethernet & .1q interfaces works with virtual devices.  AND, my
kernel module that can bridge at 990Mbps+ in both directions on a
couple of GigE interfaces also works with any ethernet-like net-device.
(Using raw sockets in user-space I cannot achieve this high of a performance.)

I can also stack virtual devices on other devices (.1q on re-direct devices,
for example).  You may very well be able to do all of these things with
tc, but it would not be worth my time to try to figure out how to change my
entire application over to support a new interface that *might* do what I
need when I can easily add a new virtual net-device that I have already proved
does what I need.

So, I'm not claiming that my code does what you want better than your
code, but I am quite certain that my code does what *I* want better
than your code.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 13:26:40 -0800
Message-ID: <424C6B10.6030200@candelatech.com>
References: <424C6089.1080507@candelatech.com> <1112303627.1073.71.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112303627.1073.71.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2005-03-31 at 15:41, Ben Greear wrote:

> I must be missing something: What is it that this device can do that the
> mirred action cant do? 
> Or in general the action framework on the ingress side?
> We can redirect to any arbitrary device; we can mirror to any arbitray
> device; we can drop, mangle packets identified via classification rules
> in any arbitrary way etc

I can operate on these devices with normal socket calls from user-space, and
can treat them as normal net_devices from kernel modules.  I do not have to
parse or manage the mirrored action logic, and I know that I absolutely have
total control over packets with my user-space language of choice.  (I am not
sure how easy it is to use your classification rules and mangling operations
in an arbitrary manner.)

I can also create a nice little set of virtual interfaces
and connections  rdd0 <-> rdd1  |bridge|  rdd2 <-> rdd3.  I can then send traffic
from rdd0 to rdd3 across the bridge, etc.  Now, this last bit is fairly
contrived, but it happens to help me with some testing on my laptop which
lacks a lot of external ethernet interfaces :)

To be honest, I didn't dig into the actions.  It would be much harder for
me to manage things in that manner, whereas virtual interfaces just work
for me.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

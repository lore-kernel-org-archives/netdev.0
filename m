From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 21:27:05 -0800
Message-ID: <424CDBA9.80703@candelatech.com>
References: <424C6089.1080507@candelatech.com> <Pine.LNX.4.61.0504010801170.6417@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.61.0504010801170.6417@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Savola wrote:
> On Thu, 31 Mar 2005, Ben Greear wrote:
> 
>> I created a new virtual ethernet device that solves a problem
>> I faced.  I thought I'd see if anyone else sees a use for this,
>> and if so, I'll work to polish the patch so that it can be
>> accepted into the kernel.
> 
> 
> Unless I'm misunderstanding..
> 
> You seem to have pretty much duplicated the work by Lennert (see thread 
> "[PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling" from January).
> 
> That particular thread seemed to conclude that instead of creating 
> something new, you can just use GRE tunneling to bridge Ethernet, and it 
> works in a multi-vendor environment as well.
> 
> Is there something in your problem statement I'm missing?

That would be similar to what I'm doing, but I'm not really trying
to tunnel anything.  I am trying to duplicate the behaviour of two
ethernet interfaces connected by an external cross-over cable, and I'm
trying to duplicate it at the network-device interface level so that
common tools (and my own tools) can treat these virtual interfaces
just like ethernet interfaces.

I think I may be the only one that needs such a thing, and since I'm
reluctant to remove the /proc interface, I don't think this will be
going into the official kernel soon.  If anyone does end up wanting
this later, I can email them my consolidated patch....

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

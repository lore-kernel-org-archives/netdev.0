From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:42:54 -0800
Message-ID: <424C7CEE.8000203@candelatech.com>
References: <424C6089.1080507@candelatech.com>	<20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>	<424C6F82.7030609@candelatech.com>	<20050331135229.432afff3.davem@davemloft.net>	<20050331140525.04f9a2b1@dxpl.pdx.osdl.net>	<424C7929.6080200@candelatech.com> <20050331143342.594b70d9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050331143342.594b70d9.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 31 Mar 2005 14:26:49 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Stephen Hemminger wrote:
>>
>>
>>>Other possiblity is adding additional attributes onto the device with sysfs.
>>>That is what net/bridge/br_sysfs_if.c does. I'm not claiming it is a pretty
>>>kernel programming model, but the user side API is simpler.
>>
>>I prefer to stay away from sysfs.  procfs may have it's faults, but at
>>least in this case, it is quite straight-forward and easily does what
>>I need.  And procfs is less encumbered by flame wars :)
> 
> 
> Are you shying away from sysfs merely for encumberance reasons?

Primarily laziness:  I know procfs and it works well for me.

> You've dissed Jamal's excellent TC action infrastructure, you're
> now dissing sysfs as well which can also solve your problems.

I don't think the TC stuff can do what I need.  However, there are
a lot less constraints on the text configuration interface, so I imagine
I can get sysfs to do what I need.

> All new interfaces are being done through sysfs, that's simply a
> fact of life in the kernel.  If you want to buck this trend, you
> have to come up with a much better argument than "procfs is more
> straight-forward".  Well if sysfs isn't as straightforward, suggest
> a layer of interfaces that might make it so.

I was not aware that procfs was off limits.  Does sysfs exist in the
2.4 kernel?  (I'll also want to backport the redirect device code to
2.4, even if just for my own kernel builds.)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

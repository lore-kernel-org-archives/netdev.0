From: Ben Greear <greearb@candelatech.com>
Subject: Re: A better way to get driver stats than parsing /proc/net/dev ?
Date: Fri, 11 Apr 2003 10:26:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E96FAE1.7030302@candelatech.com>
References: <3E967535.2000409@candelatech.com> <slrnb9dn9r.fef.lunz@stoli.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <slrnb9dn9r.fef.lunz@stoli.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> greearb@candelatech.com said:
> 
>>Is there an ioctl or some other binary means of getting the info that
>>/proc/net/dev provides?
> 
> 
> You can do it with netlink sockets. See print_linkinfo() in the iproute2
> code.

Seems that a lot of code is needed just to read the stats :(
And every man page I read says use libnetlink instead, but I can't find any docs
on libnetlink itself (and the .ru ftp link for iproute2 seems down).

Do you know of any pointers as to how to use libnetlink, or if it
really makes netlink easier to use?


> 
> Jason
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
